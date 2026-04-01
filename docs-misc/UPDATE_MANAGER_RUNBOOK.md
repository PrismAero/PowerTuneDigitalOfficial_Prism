# Update Manager Runbook

## Overview

The update manager uses private GitHub Releases and the release artifact contract in `docs-misc/UPDATE_ARTIFACT_CONTRACT.md`.

Device flow is manual:

1. Check for updates
2. Download update
3. Install update

## Required Secrets

- GitHub token with read access to the private repository.

Provision by one of:

- env: `POWERTUNE_GH_TOKEN`
- file: `/home/root/.config/PowerTune/github-token`

Optional:

- `POWERTUNE_GH_REPO` (defaults to `PowerTuneDigital/PowerTuneDigital_Prism`)
- `POWERTUNE_UPDATE_INSTALLER` (defaults to `/opt/PowerTune/Scripts/install-app-update.sh`)

## Release Publishing

GitHub workflow:

- `.github/workflows/release-app-bundle.yml`

Inputs:

- tag trigger (`v*`) or manual dispatch
- build source: `github` or `prebuilt_url`

Published assets:

- `powertune-app-bundle-<version>.tar.gz`
- `powertune-app-bundle-<version>.sha256`
- `release-manifest.json`

## Installer Behavior

Installer script:

- `Scripts/install-app-update.sh`

Behavior:

1. Set maintenance flag (`/tmp/powertune-maintenance`)
2. Stop service (`/etc/init.d/powertune stop`)
3. Backup current binary
4. Extract bundle and install binary
5. Write version metadata (`/opt/PowerTune/version.json`)
6. Start service
7. On failure, restore backup and restart previous app

## Troubleshooting

- `Missing GitHub token`
  - Provision token file or env var and retry check.
- `Manifest download failed`
  - Verify internet access and token permissions.
- `Bundle asset not found`
  - Confirm release contains all required assets.
- `Checksum verification failed`
  - Re-publish release assets; ensure manifest/checksum matches bundle.
- `Installer script not found`
  - Deploy `Scripts/install-app-update.sh` to target app path.

## Operational Notes

- This is a minimal trust model (token + checksum + TLS).
- Add signed manifests in a future hardening phase.
