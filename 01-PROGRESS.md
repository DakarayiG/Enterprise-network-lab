# Project Progress

Honest status of the build. Done means built and verified; in progress means started; planned means not yet begun. Where something was configured but not yet confirmed on the running system, it is marked accordingly.

For the full project vision, see [README.md](README.md).

---

## Status at a glance

| Phase | Component | Status |
|-------|-----------|--------|
| 1 Foundation | WSL2 Ubuntu, SSH, keys, scripts, users | Done |
| 2 Networking | VLANs, router-on-a-stick, DHCP, DNS | Done |
| 3 Security | Three-zone firewall, 3 ACLs, static routing | Done, verified with match counters |
| 4 Infrastructure | Nginx reverse proxy | Done |
| 4 Infrastructure | TLS / HTTPS (self-signed) | Done, verified live |
| 4 Infrastructure | SSH hardening | Done, verified live |
| 4 Infrastructure | MySQL | Planned |
| 4 Infrastructure | OpenLDAP (directory) | Planned |
| 5 Monitoring | Grafana | Done |
| 5 Monitoring | Loki + Promtail (logs) | Done, reboot-proof |
| 5 Monitoring | Prometheus + node_exporter (metrics) | Done, reboot-proof |
| 5 Monitoring | Zabbix | Optional / not planned |
| 6 Detection | Fail2ban (SSH brute-force) | Done, reboot-proof |
| 6 Detection | Suricata (IDS) | Planned (off-box) |
| 6 Detection | Wazuh + Kibana (SIEM) | Planned (off-box) |
| 7 Automation | Python, Ansible, Git | Planned |
| 8 Cloud | Cloud VM, VPN, hybrid | Planned |

---

## What is genuinely complete

Phases 1 to 3 are fully built, verified, and documented. The network is segmented, routed, and firewalled with a proven six-rule security policy.

Phase 4's front door is done: an Nginx reverse proxy with self-signed TLS, HTTPS on port 443, and automatic HTTP-to-HTTPS redirection. SSH is hardened (root login and password authentication disabled, key-only access). Both were confirmed live on the running system, not assumed. The remaining Phase 4 services (a database and a directory) are planned.

Phase 5 is complete. A full observability stack runs and survives reboot: Grafana dashboards reading from Loki (logs, shipped by Promtail) and Prometheus (host metrics, exposed by node_exporter). Both halves, logs and metrics, are live in one Grafana.

Fail2ban, an early piece of Phase 6, is built and running, actively protecting SSH against brute-force attempts. It is a lightweight complement to the SSH hardening, not a full detection stack. The heavier Phase 6 tools (Suricata, Wazuh, Kibana) are planned for off-box deployment because they exceed the local hardware.

---

## Build order versus architecture

Components were built iteratively, and the build order does not always match the architectural layer order. This is normal. The phase structure describes how the finished system is organised (run, watch, defend); the build sequence followed priority, what was already in progress, and what the hardware allowed. For example, Fail2ban was finished alongside the SSH hardening because it was quick and complementary, ahead of completing the monitoring layer. The metrics half of monitoring (Prometheus) was prioritised over the heavier detection stack because it runs locally and completes a layer already underway.

---

## Known open items

- The heavier infrastructure and detection components (MySQL, OpenLDAP, Suricata, Wazuh) are deferred, most to off-box environments, by hardware constraint.
- OpenLDAP is deferred additionally because centralised identity has limited value at the current single-host scale; it is planned as a demonstration once the environment grows.
- The Nginx global TLS default permits older protocol versions; the site-specific blocks correctly restrict to TLS 1.2 and 1.3. Tightening the global default is a noted minor hardening task.

---

## Next steps

1. Phase 6 detection on a persistent free-tier cloud VM (Suricata, then the Wazuh stack).
2. Phase 4 completion: MySQL, and OpenLDAP as a directory demonstration.
3. Phases 7 and 8: automation, then cloud integration.
