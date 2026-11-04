# Phase 5 — Monitoring

A complete observability stack on the WSL2 host: Grafana dashboards reading from two data sources, Loki for logs and Prometheus for metrics. Both halves are live and survive reboot.

---

## Objective

Build full visibility into the infrastructure. Logs show what happened; metrics show how the system is performing. A monitoring layer needs both, visualised together.

---

## Architecture

```
Promtail ──tails──> /var/log/*.log ──ships──> Loki ─────┐
                                                        ├──> Grafana (dashboards)
node_exporter ──exposes host metrics──> Prometheus ─────┘
```

Two parallel pipelines feeding one Grafana. The logs pipeline and the metrics pipeline follow the same shape: an agent that produces, a store that collects, Grafana that displays.

---

## Components (all verified, reboot-proof)

| Service | Port | Role |
|---------|------|------|
| Grafana | 3000 | Dashboards over both data sources |
| Loki | 3101 (behind Nginx proxy on 3100) | Log aggregation and storage |
| Promtail | 9080 | Ships system logs to Loki |
| Prometheus | 9090 | Scrapes and stores metrics |
| node_exporter | 9100 | Exposes host CPU, memory, disk, network |

All run as enabled systemd services and were confirmed active after a full `wsl --shutdown` restart.

---

## The logs half

Promtail tails `/var/log/*.log` and ships lines to Loki (job label `varlogs`). Loki stores them. Grafana queries Loki. Proven end to end: querying Loki's labels returns `varlogs`, confirming logs travelled the full chain.

## The metrics half

node_exporter reads the host and publishes metrics at port 9100. Prometheus scrapes every 15 seconds and stores the time series. Grafana queries Prometheus. Proven end to end: Prometheus reports both scrape targets up, and a Grafana Explore query (`node_memory_MemAvailable_bytes`) returns a live graph of host memory over time.

---

## Verification

```bash
# All services active
sudo systemctl is-active nginx grafana-server loki promtail fail2ban node_exporter prometheus

# Prometheus healthy and scraping
curl -s http://localhost:9090/-/healthy
curl -s "http://localhost:9090/api/v1/query?query=up"   # both targets return "1"

# Logs flowing into Loki
curl -s "http://localhost:3100/loki/api/v1/label/job/values"   # returns "varlogs"
```

---

## Troubleshooting log

**Loki proxy loop (logs pipeline).** Loki would not start: port 3100 was already bound. `ss -tlnp` showed Nginx, not Loki, held the port, and the Nginx config was proxying port 3100 to itself, a self-referential loop producing 400 errors. Fix: moved Loki to port 3101 and pointed the Nginx `proxy_pass` at 3101. Clients hit Nginx on 3100, Nginx forwards to Loki on 3101. The loop was gone.

**Prometheus service failure (metrics pipeline).** After a reboot, the Prometheus service failed with `203/EXEC`. Investigation showed the binary the service pointed at (`/etc/prometheus/prometheus`) did not exist, because it had been placed in a temporary location cleared on reboot. A filesystem search revealed Prometheus was already installed as an apt package at `/usr/bin/prometheus`, with its own user and config. Fix: pointed the systemd service at the real binary. Two lessons: manually-placed binaries must live somewhere permanent, and check what is already installed before adding your own copy.

**Service persistence.** A first reboot test exposed Grafana not enabled for boot and Fail2ban failing on a duplicated config. Both were corrected and confirmed on a second reboot. Running is not the same as enabled.

---

## Hardware note

Prometheus, node_exporter, Loki, and Promtail are all light (tens of MB each) and fit comfortably within the WSL2 memory allocation. This is why the monitoring layer runs locally, while the heavier detection stack (Phase 6) is placed off-box.

Dashboard import (the community Node Exporter dashboard, ID 1860) is a cosmetic finishing step pending; the metrics are already flowing and viewable via Grafana Explore.

---

## Skills demonstrated

- Full observability stack: logs and metrics in one Grafana
- Log aggregation pipeline (Promtail to Loki)
- Metrics pipeline (node_exporter to Prometheus)
- systemd service authoring with correct binary paths and start ordering
- Root-cause diagnosis of a proxy loop and a service execution failure
- Reboot testing to prove persistence and self-healing
