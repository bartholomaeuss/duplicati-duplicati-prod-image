# Duplicati Production Image

This repository packages a reproducible Docker image for [Duplicati](https://www.duplicati.com/) plus a couple of helper scripts that make it easy to stand up the service on fresh hosts with predictable defaults. The scripts are designed for **quick host validation, lab experiments, and troubleshooting** when you just need Duplicati up and reachable fast.

> **Warning**  
> These scripts are **not** meant for long-lived or mission-critical production deployments. They deliberately focus on speed and
> convenience rather than exhaustive hardening. Adapt the Dockerfile and automate a hardened workflow separately before using
> this image in real production.

## Why this repo?

- **Local delivery pipeline** - the image fits into my home lab setup where a local Artifactory and Tekton pipelines publish custom software images I use and keep available for fast deployments.
- **Single-command lifecycle** - `scripts/docker/run.sh` tears down existing containers, prunes dependent images, rebuilds, and restarts the container with the right mounts so test hosts always land in a clean state. The same scripts also back my [**shipit** CLI tooling](https://github.com/bartholomaeuss/shipit.git) so I can reuse the workflow across lab hosts.
- **Predictable defaults** - the image/tag (`duplicati:shipit`) and volume mappings mirror the lab layout where configuration is under `~/duplicati` and data lives on `/mnt/external_drive_*`.
- **Easy host testing** - run the script after imaging or repurposing a server to confirm storage, networking, and Docker work as expected before pushing a production stack.

## Requirements

- Docker Engine 24+ on a Linux host (tested on Ubuntu Server; adjust paths for other platforms).
- Bash 5+ (the scripts rely on `set -euo pipefail`, arrays, and process substitution).
- Host directories created ahead of time:
  - `~/duplicati`
  - `/mnt/external_drive_1/tier2`
  - `/mnt/external_drive_2/tier2`
  - `/mnt/external_drive_1/tier3`
  - `/mnt/external_drive_2/tier3`

## Repository layout

| Path | Purpose |
| --- | --- |
| `Dockerfile` | Builds the `duplicati:shipit` image from Ubuntu 20.04 and installs the selected Duplicati release. |
| `scripts/docker/run.sh` | Idempotent lifecycle helper: stop/remove containers, prune image chain, rebuild, restart. |
| `scripts/docker/prerun.sh` | Reserved for post-run hooks (empty so you can extend it). |
| `scripts/docker/postrun.sh` | Reserved for post-run hooks (empty so you can extend it). |

## Quick start

```bash
git clone https://github.com/Bartholomaeuss/duplicati-duplicati-prod-image.git
cd duplicati-duplicati-prod-image

bash scripts/docker/run.sh
```

The run script will:

1. Detect and stop any running containers created from `duplicati:shipit`.
2. Remove those containers and every image layer involved in the previous build.
3. Rebuild the image from the repository root.
4. Launch `duplicati:shipit` with host networking and the configured persistent volumes.

### Compose helpers are dev-only

The `Dockerfile` is the only artifact intended for production builds or registries. Any Compose files (`docker-compose.debug.yml`, etc.) exist solely to simplify local testing, debugging, or lab validation, except for credentials or other highly sensitive parameters that should never live in repo files. The `.vscode` and `.devcontainer` folders (and their Compose configs) are there strictly to support my VS Code development routine. Feel free to tweak or discard those helper files without affecting the production image — the Dockerfile remains the source of truth for real deployments.

### Manual Docker workflow

Prefer to run Docker commands yourself? From the repo root:

```bash
docker build -t duplicati:shipit -f Dockerfile .

docker run -d \
  --name="duplicati_shipit" \
  --net=host \
  -v ~/duplicati:/duplicati \
  -v /mnt/external_drive_1/tier2:/external_drive_1/tier2 \
  -v /mnt/external_drive_2/tier2:/external_drive_2/tier2 \
  -v /mnt/external_drive_1/tier3:/external_drive_1/tier3 \
  -v /mnt/external_drive_2/tier3:/external_drive_2/tier3 \
  --restart=unless-stopped \
  duplicati:shipit
```

Duplicati's web interface binds to `0.0.0.0:8200`, so you can connect from localhost or any LAN
client allowed to reach the host.

## Line endings and pre-commit hooks

Cloning the repo on Windows can silently convert the shell scripts to CRLF line endings, which makes `bash scripts/docker/*.sh` fail with `/bin/bash` errors and removes their executable bit inside Linux containers. To keep every script runnable:

- `.gitattributes` forces `*.sh` to stay `LF`, so Git will normalize the files even when checked out on Windows.
- `.pre-commit-config.yaml` runs `mixed-line-ending`, `end-of-file-fixer`, and `check-executables-have-shebangs` so broken or
  non-executable scripts are rejected before they land in the repo.

Install the hook runner once per clone:

```bash
pip install pre-commit
pre-commit install
```

If you already have broken checkouts, run `dos2unix scripts/docker/*.sh` to convert
them, then commit with the hooks enabled. Without these guardrails, the shell scripts will not stay executable across platforms.

## Maintenance and operations

- **Upgrade Duplicati** - bump the Duplicati image tag in `Dockerfile`.
- **Customize mounts** - update the `docker run` section in `scripts/docker/run.sh` if your storage layout differs.

### Useful CLI actions

```bash
duplicati-cli repair TARGET-URL --passphrase="PASSPHRASE"
duplicati-cli list-broken-files TARGET-URL --full-result --dbpath=PATH --passphrase="PASSPHRASE"
duplicati-cli purge-broken-files TARGET-URL --full-result --dbpath=PATH --passphrase="PASSPHRASE"
```

## Troubleshooting

- **Port 8200 already in use** - stop the conflicting service or adjust the command-line arguments in the Dockerfile.
- **Missing host folders** - create the expected directories before running the script; otherwise Docker may create root-owned folders with the wrong permissions.
- **Docker permission errors** - add your user to the `docker` group or run the commands with `sudo`.
- **Image cleanup failures** - if `remove_image_chain` in `run.sh` cannot prune older layers, run `docker image ls` and remove them manually.

## Further reading

- [Duplicati documentation](https://docs.duplicati.com/)
- [Installation guide](https://docs.duplicati.com/getting-started/installation)
- [Using Duplicati from Docker](https://docs.duplicati.com/detailed-descriptions/using-duplicati-from-docker)
- [Duplicati CLI reference](https://docs.duplicati.com/duplicati-programs/command-line-interface-cli)
