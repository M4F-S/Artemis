# 25 — Local Dev Runbook

Step-by-step from clean machine to running Artemis agent locally. Aimed at a contributor's first day.

## Prerequisites

- Linux host (Ubuntu 22.04+ or 24.04 recommended). macOS / Windows can use the devcontainer.
- 8+ GB RAM, 4+ cores.
- Either: VS Code + Docker (for devcontainer), or `nix` 2.18+ (for nix flake), or a manual local toolchain.
- A GitHub account with access to the repo.

## Path 1: devcontainer (easiest)

```bash
git clone <repo-url> artemis
cd artemis
# In VS Code: "Reopen in Container" — pulls Ubuntu 24.04 base + Rust + aya-tool + clang + pnpm.
# Wait ~5–10 minutes the first time.
```

Inside the container:

```bash
cargo build --workspace
cargo test --workspace
```

If both commands succeed, you're set up.

## Path 2: nix flake (reproducible)

```bash
git clone <repo-url> artemis
cd artemis
nix develop          # drops you into a shell with the exact toolchain
cargo build --workspace
```

## Path 3: manual local toolchain

Install:
- Rust stable + nightly via `rustup`.
- `cargo install cargo-bpf cargo-deny`.
- Clang, LLVM, kernel headers (`apt install clang llvm linux-headers-$(uname -r)`).
- Node LTS + pnpm.

Then:

```bash
cargo build --workspace
```

## Running the daemon locally (Phase 1+)

```bash
# one-time: copy the sample dev config into place
cp samples/agent.toml.example dev/agent.toml

cargo build -p artemis-agentd --release
sudo ./target/release/artemis-agentd --config dev/agent.toml
```

The dev `agent.toml` (provided in `samples/agent.toml.example`) points the daemon at:
- An ingest stub on `localhost:4317` (start it separately, see below).
- mTLS disabled in dev mode.
- Rules loaded from `rules/pack-v0/`.
- Local SQLite at `./spool/events.db` for the offline buffer.

Why `sudo`: eBPF program loading needs `CAP_BPF`. In production the daemon will run as a dedicated capability-restricted user; in dev, `sudo` is the simple path.

## Running the ingest stub locally

```bash
cargo run -p artemis-ingest -- --listen 127.0.0.1:4317 --dev-no-mtls
```

The stub writes events to `./spool/ingest.log` so you can verify the agent → ingest path is working without standing up Kafka or ClickHouse.

## Running the console locally

```bash
cd apps/console
pnpm install
pnpm dev   # http://localhost:3000
```

In dev, the console connects to the local ingest stub.

## Verifying end-to-end (Phase 1 minimum)

With agent + ingest stub + console all running:

1. In another terminal, run a benign workload (`ls`, `curl`, `cat /etc/hosts`). The agent should observe these but emit no alerts.
2. Trip a canary file: `cat ~/.aws/credentials.canary` (the deception placer puts one here in dev mode). The console should display a HIGH alert within ~1 second.
3. Try to load an unauthorised eBPF program (test with `bpftool prog load /usr/lib/bpf/test.bpf.o /sys/fs/bpf/test`). The agent should alert on the load.

## Common issues

| Symptom | Likely cause | Fix |
|---|---|---|
| `cargo build` fails on `artemis-bpf` with "no `bpfel-unknown-none` target" | nightly toolchain not installed | `rustup target add bpfel-unknown-none --toolchain nightly` |
| Daemon panics with `EPERM` when loading eBPF | running without `sudo` or `CAP_BPF` | `sudo ./target/release/artemis-agentd ...` |
| eBPF verifier rejection: "BPF_PROG_LOAD: invalid argument" | kernel too old or CO-RE drift | check `uname -r`; minimum 5.10 with CONFIG_BPF_LSM=y |
| `pnpm install` fails with `EACCES` | running as root in container | exit container, re-enter as the configured user |
| Ingest stub binds but agent can't connect | firewall on lo? | unlikely on dev; check `ss -tlnp 4317` |

## Tearing down

```bash
# stop daemon (Ctrl+C in its terminal or):
sudo pkill artemis-agentd

# clear local state (warning: destructive):
rm -rf ./spool ./target/debug ./target/release
```

## When you're stuck

1. Re-read the relevant pillar doc.
2. Check `docs/14-session-handoff.md` for any recent change that might be the cause.
3. Ask in the team channel; include `uname -r`, `cargo --version`, the exact command, and the full error.
4. If you believe it's a CI / kernel matrix issue, file an issue tagged `bug:env`.

## Performance test locally

```bash
# from repo root:
cargo run -p artemis-agentd --release -- --config dev/agent.toml &
AGENT_PID=$!
# wait for steady state:
sleep 30
# read CPU / RSS:
ps -p $AGENT_PID -o %cpu,rss
# kill:
kill $AGENT_PID
```

Production budget is < 2% CPU sustained, < 150 MB RAM at idle. The dev build will be louder; release with optimisations should be quiet.
