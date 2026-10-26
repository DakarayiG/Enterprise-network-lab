# Phase 3 — Network Security & Three-Zone Firewalling

Cisco Packet Tracer implementation of a segmented enterprise perimeter using a firewall router, three security zones, and extended ACLs enforcing a six-rule access policy.

![Phase 3 Topology](phase3-security-diagram.png)

---

## Objective

Extend the Phase 2 routed network into a defended perimeter. Separate traffic into three trust zones, place a firewall router between them, and enforce a written security policy using Access Control Lists. Prove every rule with live match-counter evidence rather than assuming it works.

---

## Architecture

Three zones, ordered by trust level.

| Zone | Trust | Network | Key Host |
|------|-------|---------|----------|
| WAN | Untrusted | 10.0.0.0/8 | Attacker-PC `10.0.0.2` |
| DMZ | Semi-trusted | 192.168.50.0/24 | Web-Server `192.168.50.2` |
| LAN | Trusted | 192.168.10.0/24, .20.0/24, .30.0/24 | Phase 2 VLANs |

The DMZ exists to host the public web server where external traffic can reach it, while keeping that server walled off from the internal LAN. A compromised web server becomes a dead end instead of a pivot point.

---

## Device Addressing

### Firewall-Router (Cisco 2911)

| Interface | IP Address | Zone |
|-----------|-----------|------|
| Gig0/0 | 10.0.0.1 | WAN |
| Gig0/1 | 192.168.50.1 | DMZ |
| Gig0/2 | 172.16.0.1 | LAN link |

### Core-Router (Cisco 2911)

| Interface | IP Address | Purpose |
|-----------|-----------|---------|
| Gig0/1 | 172.16.0.2 | Link to Firewall-Router |
| Gig0/0 sub-ifs | 192.168.10.1 / .20.1 / .30.1 | Phase 2 VLAN gateways |

### End Hosts

| Device | IP Address | Zone |
|--------|-----------|------|
| Attacker-PC | 10.0.0.2 | WAN |
| Web-Server | 192.168.50.2 | DMZ |
| Management-PC | 192.168.10.11 | LAN (VLAN 10) |
| Server-PC | 192.168.20.11 | LAN (VLAN 20) |
| DNS-Server | 192.168.20.2 | LAN (VLAN 20) |
| Client-PC | 192.168.30.11 | LAN (VLAN 30) |

---

## Routing

A 172.16.0.0/24 transit link joins the two routers. Static routes carry traffic in both directions.

**Core-Router** (reaching the DMZ and WAN through the firewall):
```
ip route 192.168.50.0 255.255.255.0 172.16.0.1
ip route 10.0.0.0 255.0.0.0 172.16.0.1
```

**Firewall-Router** (reaching the three LAN subnets through the core):
```
ip route 192.168.10.0 255.255.255.0 172.16.0.2
ip route 192.168.20.0 255.255.255.0 172.16.0.2
ip route 192.168.30.0 255.255.255.0 172.16.0.2
```

---

## Security Policy

Six rules define what each zone may reach.

| # | Rule | Action |
|---|------|--------|
| 1 | LAN to DMZ | Permit |
| 2 | LAN to Internet | Permit |
| 3 | DMZ to LAN | Deny |
| 4 | Internet to DMZ | Permit, HTTP/HTTPS only |
| 5 | Internet to LAN | Deny |
| 6 | Established return traffic | Permit |

Rule 3 is the core of the design. It prevents lateral movement from a breached web server into the internal network.

---

## ACL Implementation

Three extended ACLs, each applied inbound on the interface facing its zone. Filtering inbound means inspecting traffic as it enters the firewall from each zone, which is the standard and most efficient placement.

### WAN-IN (applied inbound on Gig0/0)

Allows the Internet to reach only the web server on HTTP/HTTPS, permits return traffic for sessions the LAN initiated, and blocks everything else headed for the internal network.

```
ip access-list extended WAN-IN
 permit tcp any host 192.168.50.2 eq 80
 permit tcp any host 192.168.50.2 eq 443
 permit tcp any 192.168.10.0 0.0.0.255 established
 permit tcp any 192.168.20.0 0.0.0.255 established
 permit tcp any 192.168.30.0 0.0.0.255 established
 permit icmp any 192.168.10.0 0.0.0.255 echo-reply
 permit icmp any 192.168.20.0 0.0.0.255 echo-reply
 permit icmp any 192.168.30.0 0.0.0.255 echo-reply
 deny ip any 192.168.10.0 0.0.0.255
 deny ip any 192.168.20.0 0.0.0.255
 deny ip any 192.168.30.0 0.0.0.255
interface gigabitEthernet0/0
 ip access-group WAN-IN in
```

### DMZ-IN (applied inbound on Gig0/1)

Lets the web server resolve DNS and answer visitors, but explicitly blocks it from reaching the LAN. This enforces Rule 3.

```
ip access-list extended DMZ-IN
 permit udp host 192.168.50.2 host 192.168.20.2 eq 53
 permit tcp host 192.168.50.2 host 192.168.20.2 eq 53
 permit tcp host 192.168.50.2 any established
 permit icmp host 192.168.50.2 any echo-reply
 deny ip host 192.168.50.2 192.168.10.0 0.0.0.255
 deny ip host 192.168.50.2 192.168.30.0 0.0.0.255
 permit ip host 192.168.50.2 any
interface gigabitEthernet0/1
 ip access-group DMZ-IN in
```

### LAN-IN (applied inbound on Gig0/2)

The trusted zone. Permits internal traffic outbound to the DMZ and the Internet.

```
ip access-list extended LAN-IN
 permit ip 192.168.10.0 0.0.0.255 192.168.50.0 0.0.0.255
 permit ip 192.168.20.0 0.0.0.255 192.168.50.0 0.0.0.255
 permit ip 192.168.30.0 0.0.0.255 192.168.50.0 0.0.0.255
 permit ip 192.168.10.0 0.0.0.255 any
 permit ip 192.168.20.0 0.0.0.255 any
 permit ip 192.168.30.0 0.0.0.255 any
interface gigabitEthernet0/2
 ip access-group LAN-IN in
```

---

## The Established and Echo-Reply Keywords

A ping or web request is two separate packets travelling opposite directions. The request leaves and the reply must return. An ACL that only permits the outbound half silently drops the reply, and the connection appears broken even though the rule looks correct.

Two keywords handle this:

- `established` matches TCP packets that belong to a session already underway. Return traffic for a connection the LAN opened passes. A connection the outside tries to open does not.
- `echo-reply` matches ping answers, not ping attempts. Internal hosts can ping out and receive replies, while outside hosts cannot ping in.

Together these deliver stateful-style return handling on a stateless router. This pairing is Rule 6.

---

## Verification

Every rule was proven with `show access-lists` match counters after generating live traffic. Counters moving off zero is the evidence. A failed ping alone proves nothing, since a blocked packet and a broken link look identical from the sending host.

| Rule | Test | Result | Evidence |
|------|------|--------|----------|
| 1 | Management-PC ping Web-Server | Success | LAN-IN permit line incremented |
| 2 | Management-PC ping 10.0.0.2 | Success | LAN-IN permit line incremented |
| 3 | Web-Server ping LAN hosts | Blocked | DMZ-IN deny lines incremented |
| 4 | Attacker browse http://192.168.50.2 | Page loads | WAN-IN port-80 line incremented |
| 5 | Attacker ping LAN | Blocked, "Destination host unreachable" | WAN-IN deny enforced |
| 6 | Return traffic for LAN-initiated sessions | Success | WAN-IN echo-reply line incremented |

A detail worth noting on Rule 5: the firewall replied with "Destination host unreachable" from its own interface address rather than timing out. An active rejection from the router confirms the ACL dropped the packet. A timeout would have meant a path problem instead. The distinction is how you tell a working firewall from a broken link.

---

## Troubleshooting Log

Two real failures surfaced during the build. Both taught more than the config itself.

### 1. Swapped cables between DMZ and LAN link

**Symptom.** Web-Server could not ping its own gateway (192.168.50.1), 100 percent loss.

**Investigation.** Walked the path hop by hop from the server outward. `show ip interface brief` on the firewall reported Gig0/1 as up/up, which ruled out a shut interface. Hovering over the cables in the topology revealed the truth: the Web-Server cable landed on Gig0/2 (the 172.16 LAN-link interface) and the Core-Router cable landed on Gig0/1 (the 192.168.50 DMZ interface). The two were plugged into each other's ports.

**Lesson.** An interface showing up/up confirms the port is live. It does not confirm the right cable is in it. Link lights were green the whole time because the cables were connected, just to the wrong interfaces. Green plus wrong is still wrong.

**Fix.** Re-cabled Web-Server to Gig0/1 and Core-Router to Gig0/2. Links came up and the gateway ping succeeded.

### 2. Lost configuration from an unsaved session

**Symptom.** After reopening the lab, `show access-lists` returned empty and `show ip route static` was blank. Interface IPs survived but the ACLs, static routes, and the cabling fix were gone.

**Investigation.** The firewall held its interface addresses but nothing added afterward. That pattern pointed at a config saved at an earlier checkpoint, with all later work lost when the session closed without saving.

**Lesson.** Cisco devices keep two configs. The `running-config` lives in RAM and is wiped on reload. The `startup-config` lives in NVRAM and survives. Commands take effect in RAM immediately but vanish unless copied to NVRAM. In Packet Tracer there is a second layer: the `.pkt` file on disk holds the whole simulation. Saving one layer without the other still loses work.

**Fix and standing habit.** After any meaningful change:
```
copy running-config startup-config
```
on every router touched, then **File > Save** in Packet Tracer. Both layers, every time.

---

## Skills Demonstrated

- Perimeter network design with DMZ segmentation
- Extended ACL construction, ordering, and inbound placement
- Stateful-style return handling with `established` and `echo-reply`
- Static routing across a transit link
- Structured hop-by-hop fault isolation
- Evidence-based verification using match counters
- Running-config versus startup-config persistence

---

## Files

| File | Description |
|------|-------------|
| `phase3-security-lab.pkt` | Packet Tracer lab file |
| `phase3-security-diagram.png` | Three-zone topology diagram |
| `README.md` | This document |
