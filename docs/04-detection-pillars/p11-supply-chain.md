# P11 — Supply-Chain Runtime Guard

**Gap closed:** Tier 3 #12. npm/pypi typosquatting +104% YoY; Axios incident, TeamPCP, Shai-Hulud worm. Static SCA tools (Snyk, Socket, Dependabot) help at install time but miss runtime behaviour, and the install-script attack window is short and painful.

## Threat surface

- Direct typosquats (`reqeusts`, `axoios`).
- Dependency confusion (private name shadowed by public registry).
- Compromised legitimate packages (post-publication or via maintainer takeover).
- Malicious post-install / preinstall hooks.
- Wormable build-tool plugins (Trivy, ESLint plugins, cargo subcommands).

## Detection at runtime

### Install-time hooks
- **Linux/macOS:** an LD_PRELOAD-free shim around `npm`/`pnpm`/`yarn`/`pip`/`uv`/`cargo install`. The shim is opt-in and chains through to the real tool.
- **Windows:** ETW + named-pipe consumer of common package managers.

When a package is installed, Artemis:
1. Resolves the SBOM diff (was anything new added?).
2. Cross-references each new package against:
   - Tenant's package-allowlist.
   - Recent published-then-yanked indicators (community feed).
   - Sus-name heuristics (Levenshtein distance to top-1k packages, similarly-spelled UTF-8 confusables).
   - Maintainer-account-recency and 2FA status (queried per registry API).
3. Sandboxes the package's lifecycle scripts (`postinstall` etc.) in an ephemeral microVM (Firecracker on Linux) or a lightweight Win32 sandbox; observes behaviour for 30s.

Behaviour red flags during sandbox:
- Reads of `~/.aws`, `~/.ssh`, browser cookies, password managers.
- Outbound to non-registry, non-source-control endpoints.
- Process spawning beyond compilation toolchains.
- File writes outside `node_modules` / build paths.

If red flags ≥ N → block install + alert.

### First-run hooks
- A package that survived install-time may still misbehave at first runtime use.
- Userland daemon tracks per-package call sites (best-effort) and applies the same red-flag set on first-run for a configurable window.

### Per-package egg-shell (advanced, opt-in)
- Tenants who care can run dev fleets with a per-package syscall sandbox: Node modules executed under a Wasm or `bwrap` jail with declared capabilities only. Friction is real; default off.

## Build-system coverage

- GitHub Actions runner agent: Artemis can ship a self-hosted runner that emits the same telemetry → catches CI-side compromises (Trivy / Shai-Hulud-class).

## Limitations

- We can only protect machines we run on. Centralised enforcement at the registry level is out of scope.
- Microvm install-sandbox adds 1–3 s to each new install; acceptable for dev workflows, configurable.

## Coverage

- ATT&CK: T1195.002 (Compromise Software Supply Chain), T1059 (Command & Scripting Interpreter), T1552.001 (Credentials in Files).
