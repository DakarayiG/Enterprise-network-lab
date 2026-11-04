# Enterprise Network & Security Lab

A build-from-scratch enterprise lab spanning Linux administration, network engineering, security, infrastructure, monitoring, detection, automation, and cloud. Built on constrained hardware (an 8GB Windows 11 host running Ubuntu under WSL2, plus Cisco Packet Tracer) to demonstrate the full lifecycle of a defended, observable network.

This document describes the complete project vision across all eight phases. For current build status, see [PROGRESS.md](PROGRESS.md).

---

## The through-line

The project layers control from the ground up: build the network, secure it, watch it, defend it, automate it, and extend it to the cloud. Each phase assumes the one before. You cannot filter between zones you have not separated, or detect intrusions on a network you cannot observe.

---

## The eight phases

### Phase 1 — Foundation
Linux and WSL2 administration. A working Ubuntu environment, SSH server with key-based authentication, user and group management, file permissions, and bash scripting for system and network reporting.

### Phase 2 — Networking Core
A routed, segmented network in Cisco Packet Tracer. Three VLANs (Management, Servers, Clients), inter-VLAN routing via router-on-a-stick, DHCP per VLAN, and internal DNS. A star topology at the access layer.

### Phase 3 — Security
A three-zone perimeter: WAN (untrusted), DMZ (public web server), and LAN (trusted internal). A firewall router enforces a six-rule access policy through extended ACLs, with static routing stitching the zones together.

### Phase 4 — Infrastructure
Core services. An Nginx reverse proxy with self-signed TLS/HTTPS as the front door, SSH hardening, and foundational services (a database, and a directory service for centralised identity).

### Phase 5 — Monitoring
Full observability. Grafana dashboards over two data sources: Loki for log aggregation (shipped by Promtail) and Prometheus for host metrics (exposed by node_exporter). Logs and metrics in one place.

### Phase 6 — Detection
Threat detection beyond basic blocking. Suricata as an intrusion detection system inspecting traffic, Wazuh as a SIEM correlating security events, and a dashboard visualising attacks. Deployed off-box on a cloud VM due to resource weight.

### Phase 7 — Automation
Moving from manual to programmatic. Python networking scripts, Ansible playbooks for repeatable configuration, and Git-based version control of infrastructure.

### Phase 8 — Cloud Integration
Extending on-premises into the cloud. A cloud VM, site-to-site VPN, hybrid topology, and cloud-based monitoring.

---

## Hardware constraint as a design driver

The 8GB host shapes the architecture throughout. WSL2 receives roughly half the host RAM (about 3.5GB). Light services run locally; heavy ones (the SIEM stack, a full identity platform) are deliberately placed off-box on free-tier cloud or container environments. Resource-aware placement is treated as an engineering decision, documented where it applies, rather than an afterthought.

---

## Tooling by phase

| Phase | Primary tools |
|-------|---------------|
| 1 Foundation | WSL2 Ubuntu, OpenSSH, bash, Git |
| 2 Networking | Cisco Packet Tracer |
| 3 Security | Cisco Packet Tracer (ACLs, zones) |
| 4 Infrastructure | Nginx, OpenSSL, MySQL, OpenLDAP |
| 5 Monitoring | Grafana, Loki, Promtail, Prometheus, node_exporter |
| 6 Detection | Suricata, Wazuh, Kibana (off-box) |
| 7 Automation | Python, Ansible, Git |
| 8 Cloud | Oracle Cloud / AWS free tier, VPN |

---

## Repository structure

```
Enterprise-network-lab/
├── README.md                  # This file (project vision)
├── PROGRESS.md                # Current build status
├── phase-1-foundation/
├── phase-2-networking/
├── phase-3-security/
├── phase-4-infrastructure/
├── phase-5-monitoring/
└── (phases 6-8 to follow)
```

Each phase folder contains its own README with the detailed build, configuration, verification, and skills demonstrated.
