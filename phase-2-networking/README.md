# Phase 2 — Networking Core

## Overview
Built a segmented enterprise network using Cisco 
Packet Tracer with VLANs, inter-VLAN routing, 
DHCP and DNS. This phase covers CCNA level 
networking concepts.

## Network Topology
- 1x Cisco 2911 Router (Core-Router)
- 1x Cisco 2960 Switch (Access-Switch)
- 3x PCs (Management, Server, Client)
- 1x DNS Server

## VLAN Design
| VLAN | Name | Network | Gateway |
|---|---|---|---|
| 10 | Management | 192.168.10.0/24 | 192.168.10.1 |
| 20 | Servers | 192.168.20.0/24 | 192.168.20.1 |
| 30 | Clients | 192.168.30.0/24 | 192.168.30.1 |

## IP Addressing
| Device | VLAN | IP Address | Method |
|---|---|---|---|
| Core-Router Gi0/0.10 | 10 | 192.168.10.1 | Static |
| Core-Router Gi0/0.20 | 20 | 192.168.20.1 | Static |
| Core-Router Gi0/0.30 | 30 | 192.168.30.1 | Static |
| DNS-Server | 20 | 192.168.20.2 | Static |
| Management-PC | 10 | 192.168.10.11 | DHCP |
| Server-PC | 20 | 192.168.20.11 | DHCP |
| Client-PC | 30 | 192.168.30.11 | DHCP |

## Switch Port Assignment
| Port | Mode | VLAN | Device |
|---|---|---|---|
| Fa0/1 | Trunk | All | Core-Router |
| Fa0/2 | Access | 10 | Management-PC |
| Fa0/3 | Access | 20 | Server-PC |
| Fa0/4 | Access | 30 | Client-PC |
| Fa0/5 | Access | 20 | DNS-Server |

## What I Built
- Created and named 3 VLANs
- Configured trunk port to router
- Set up router on a stick (sub-interfaces)
- Configured inter-VLAN routing
- Set up DHCP pools for all VLANs
- Deployed DNS server with A records
- Tested cross-VLAN communication

## Cisco Commands Used
### Switch Commands
- vlan [id] - create VLAN
- name [name] - name the VLAN
- switchport mode access - set access port
- switchport access vlan [id] - assign to VLAN
- switchport mode trunk - set trunk port
- show vlan brief - verify VLANs
- show interfaces trunk - verify trunk

### Router Commands
- interface Gi0/0.[id] - create sub-interface
- encapsulation dot1Q [id] - tag VLAN traffic
- ip address [ip] [mask] - assign IP
- no shutdown - enable interface
- ip dhcp pool [name] - create DHCP pool
- network [ip] [mask] - define DHCP network
- default-router [ip] - set gateway for DHCP
- dns-server [ip] - set DNS for DHCP
- ip dhcp excluded-address - reserve IPs
- show ip interface brief - verify interfaces
- show ip dhcp binding - see DHCP leases

## Key Concepts Learned
- VLANs segment network traffic logically
- Trunk ports carry multiple VLANs
- Router on a stick uses sub-interfaces
- DHCP automates IP assignment
- DNS translates hostnames to IPs
- Inter-VLAN routing requires a router

## Test Results
- Management-PC ping Server-PC: ✅
- Management-PC ping Client-PC: ✅
- Client-PC ping management.lab: ✅
- Client-PC ping server.lab: ✅
- DHCP auto assignment all VLANs: ✅

## Files
- phase2-network-lab.pkt - Packet Tracer file
- phase2-network-diagram.png - Network diagram
