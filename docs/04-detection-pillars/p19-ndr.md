# P19 — Network Detection & Response (NDR)

EDR is endpoint-blind to lateral movement, C2 over legit hosts, and unmanaged devices on the LAN. P19 fills the gap with **lightweight, encrypted-traffic-aware** sensors.

## Sensor modes

- **Tap / SPAN**: passive packet collection from a switch mirror port at the customer site.
- **Endpoint co-sensor**: where deploying network gear is impractical, use the endpoint sensor's existing eBPF / WFP / NetExt hooks to emit per-flow metadata as if it were a network sensor (degraded but better than nothing).
- **Cloud VPC traffic mirroring** for cloud workloads (AWS VPC Traffic Mirroring, GCP Packet Mirroring, Azure VTAP).

## Detection

### N1 Encrypted-traffic analysis

- TLS fingerprinting (JA4 / JA4S / JA4H suite); cluster on client + server fingerprint pairs.
- Beacon detection on inter-arrival timing across encrypted flows.
- Certificate-pinning + CT-log cross-check on rare destinations.

### N2 Lateral movement

- Host-pair graph; first-time-seen edges flagged.
- SMB / RDP / WinRM / SSH event-based detection at the network layer (back-stop for endpoint sensor gaps).
- Kerberoasting / PtH / PtT signatures based on Kerberos packet shapes.

### N3 Unmanaged-device discovery

- Passive device fingerprinting (OS, vendor, role).
- Diff against the agent-managed host inventory — anything seen on the LAN but not in the agent fleet = UNMANAGED.
- Critical for SMBs who think they have 100 endpoints but actually have 130.

### N4 DNS / DGA / tunnelling

- DGA classifier on observed query stream.
- DNS tunnelling detection (entropy, query rate, response sizes).
- Newly-registered-domain (NRD) detection via passive-DNS + WHOIS.

### N5 C2 over legit infrastructure

- Beacon detection on Cloudflare / GitHub / Slack / Discord / Telegram / pastebins — the modern attacker's preferred C2 layer.
- Frequency + JA4 + SNI pattern combine into a "looks like beaconing" score.

## Privacy

- Default: only metadata + verdicts leave the customer site; payloads stay on a tenant-local appliance.
- Optional payload capture for forensics (off by default; explicit consent).

## Coverage

- ATT&CK: TA0008 (Lateral Movement), TA0011 (C2), T1071 (Application Layer Protocol), T1572 (Protocol Tunneling), T1568 (Dynamic Resolution).
