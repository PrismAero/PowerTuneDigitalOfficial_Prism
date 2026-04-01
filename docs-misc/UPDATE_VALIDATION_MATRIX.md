# Update Validation Matrix

## Build-Time Validation

- Status: PASS
- Evidence: Windows debug compile succeeded after updater integration (`Scripts/build-windows-ninja.ps1 -NoDeploy`).

## Scenario Matrix

| Scenario | Expected | Validation Status | Notes |
| --- | --- | --- | --- |
| No update available | Updater shows idle/no update | PASS (code path) | `UpdateManagerService::handleReleaseResponse` sets idle when latest <= current |
| Update available + install success | Download verified, install script runs, status success | PASS (code path) | `downloadReady` + `installUpdate()` happy path implemented |
| Bad checksum | Install blocked with error | PASS (code path) | `verifyDownloadedBundle()` enforces SHA256 match |
| Interrupted download | Error state shown | PASS (code path) | Reply error path sets status `error` |
| Missing/invalid token | Check blocked with auth error | PASS (code path) | `checkForUpdates()` requires token and reports missing auth |
| Installer failure + rollback | Previous binary restored | PASS (script path) | `Scripts/install-app-update.sh` restores backup on restart failure |

## Manual Device Tests Pending

The following still require on-device execution against a private GitHub release:

1. Manual check/download/install end-to-end on Raspberry Pi target.
2. Real network interruption during bundle transfer.
3. Invalid token runtime test with GitHub API 401 handling.
4. Forced service restart failure to verify rollback in production environment.

## Suggested Manual Test Procedure

1. Provision token to `/home/root/.config/PowerTune/github-token`.
2. Publish a test release with contract assets.
3. Use Settings -> Updates:
   - Check for updates
   - Download update
   - Install update
4. Confirm app restarts and `/opt/PowerTune/version.json` updates.
5. Repeat with intentionally broken checksum release to confirm rejection.
