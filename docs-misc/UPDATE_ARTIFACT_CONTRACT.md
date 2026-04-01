# Update Artifact Contract

This document defines the release payload consumed by the in-device update manager.

## Canonical Files Per Release

Each release must publish the following assets:

- `powertune-app-bundle-<version>.tar.gz`
- `powertune-app-bundle-<version>.sha256`
- `release-manifest.json`

Example:

- `powertune-app-bundle-v1.2.3.tar.gz`
- `powertune-app-bundle-v1.2.3.sha256`
- `release-manifest.json`

## Bundle Layout

The tarball must contain a single top-level directory:

- `powertune-app-bundle-<version>/`
  - `PowerTuneQMLGui`
  - optional runtime assets required by that build

## release-manifest.json Schema

```json
{
  "version": "v1.2.3",
  "platform": "linux-armv7",
  "bundle_file": "powertune-app-bundle-v1.2.3.tar.gz",
  "checksum_file": "powertune-app-bundle-v1.2.3.sha256",
  "sha256": "hex-string",
  "published_at_utc": "2026-04-01T12:34:56Z",
  "release_notes_url": "https://github.com/<owner>/<repo>/releases/tag/v1.2.3"
}
```

## Checksum File Format

Checksum file must be compatible with `sha256sum -c`:

```text
<sha256>  <bundle_filename>
```

## Compatibility Rule

The device updater accepts a release only if:

1. `manifest.version` is newer than installed version
2. bundle and checksum assets exist in the same release
3. computed SHA256 of downloaded bundle equals manifest/checksum value

## Producer Paths

This contract is shared across two producer modes:

- GitHub build-and-release workflow
- Local build server pipeline that publishes assets to GitHub Releases

Both producers must emit assets that exactly match this contract.
