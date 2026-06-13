# Dogbox Releases — Claude Code Context

> Read this before touching any file.

---

## What This Repo Is

Release hosting for the Dogbox app. GitHub serves the raw files; the app's
auto-updater and install scripts fetch from here.

Related repos:
- **dbox** (`../dbox`) — the Dogbox Accounting app source; releases are built from there
- **dbox-website** (`../dbox-website`) — marketing website
- **dbox-investments** (`../dbox-investments`) — Dogbox Investments app; `install_dinv_stub.*` files in this repo relate to it

---

## Files

| File | Purpose |
|------|---------|
| `version.json` | Authoritative version manifest — read by the auto-updater |
| `version.txt` | Plain-text version number (legacy fallback) |
| `dbox.zip` | Latest release build |
| `DogboxInstall.command` | macOS installer script |
| `install_dbox.bat` | Windows installer script |
| `install_stub.ps1 / .sh` | Lightweight install stubs |
| `install_dinv_stub.ps1 / .sh` | Dogbox Investments install stubs |

---

## version.json Schema

```json
{
  "version": "X.Y.Z",
  "notes": "Release notes markdown string",
  "url": "https://github.com/davidrobertinnes/dbox-releases/raw/main/dbox.zip"
}
```

`notes` is a raw markdown string — include all changelog entries for the release.

---

## Release Process

Releases are cut from the `dbox` repo. Steps:

1. In `dbox`: build the zip, update `CHANGELOG.md`, tag the commit
2. Copy the new `dbox.zip` into this repo
3. Update `version.json` (version + notes) and `version.txt`
4. Commit and push — the auto-updater polls `version.json` via GitHub raw URL

The licenser (`dbox/licenser/`) tracks which version each customer is on.
