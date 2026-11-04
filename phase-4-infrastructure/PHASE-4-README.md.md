# Phase 4 — Infrastructure

Core services on the WSL2 Ubuntu host: an Nginx reverse proxy with TLS/HTTPS as the secure front door, and SSH hardening. Database and directory services are planned.

---

## Objective

Establish the foundational infrastructure that applications and services sit on: a secured entry point, encrypted transport, and hardened host access.

---

## What is built and verified

### Nginx reverse proxy

Nginx acts as the single front door, routing traffic to internal services (Grafana, Loki) rather than exposing each directly. A reverse proxy terminates connections at one controlled point and forwards inward.

### TLS / HTTPS (verified live)

HTTPS is configured and active, confirmed on the running system with `nginx -T`:

- Self-signed RSA certificate and key present on disk
- `listen 443 ssl` with the certificate and key loaded
- `ssl_protocols TLSv1.2 TLSv1.3` on the site blocks (modern, safe versions)
- Automatic HTTP-to-HTTPS redirect (`return 301 https://...`)

The certificate key is permissioned to owner-only read, which is correct practice.

### SSH hardening (verified live)

Confirmed active with `sshd -T` and the live config:

- `PermitRootLogin no` (root cannot log in)
- `PasswordAuthentication no` (no password login)
- `PubkeyAuthentication yes` (key-only access)

This builds directly on the key pair generated in Phase 1, enforcing that only key-based access is accepted.

---

## Verification commands

```bash
# SSH hardening (active directives)
sudo grep -vE '^\s*#|^\s*$' /etc/ssh/sshd_config

# TLS config as loaded by Nginx
sudo nginx -T 2>/dev/null | grep -E 'ssl_certificate|ssl_protocols|listen 443|return 301'

# Certificate files on disk
ls -la /etc/nginx/ssl/
```

All three were run and confirmed. TLS and SSH hardening are verified active, not assumed.

---

## Known hardening note

Nginx's global default config still permits older protocol versions (TLSv1, TLSv1.1) in a default `ssl_protocols` line, though the site-specific server blocks correctly restrict to TLS 1.2 and 1.3, so the actual HTTPS endpoints are safe. Tightening the global default to drop the deprecated versions is a noted minor improvement.

---

## Planned

- **MySQL** — a relational database as a foundational stateful service.
- **OpenLDAP** — a directory service for centralised identity. Deferred because at the current single-host scale there is nothing to centralise; planned as a demonstration of the concept once the environment grows to multiple hosts. Chosen over FreeIPA, which is too heavy for the 8GB host.

---

## Skills demonstrated

- Reverse-proxy architecture with a single controlled entry point
- TLS/SSL configuration with self-signed certificates and HTTP-to-HTTPS redirection
- SSH hardening (disabling root login and password authentication, enforcing key-only access)
- Verifying security configuration against the live system rather than assuming it
