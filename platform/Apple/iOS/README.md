# NBlood for iOS (unsigned IPA)

Software-renderer build of NBlood for arm64 iOS 16+, sideloadable via
AltStore / LiveContainer. No Xcode IDE required — builds with the iphoneos
clang toolchain only.

## Build

```sh
bash platform/Apple/iOS/build_ipa.sh
```

Produces `platform/Apple/iOS/build/NBlood.ipa`. Override knobs:
`IOS_MIN` (default 16.0), `OUT` (output dir), `JOBS`.

Prerequisite: a one-time cross-built static SDL2 staged at
`platform/Apple/iOS/SDL2/{include,lib}` (libSDL2.a + libSDL2main.a). See
`ios-build-recipe` in the project memory for the CMake commands.

## Install the game data

The IPA bundles only NBlood's own `nblood.pk3`. You must supply the
copyrighted Blood data files yourself. After installing the app:

1. Open the **Files** app (or Finder on macOS with the device connected).
2. Go to **On My iPhone → NBlood** (file sharing is enabled in Info.plist).
3. Copy your Blood data files into that folder (the app's `Documents`):
   - `blood.rff`, `gui.rff`, `sounds.rff`
   - `blood.ini`
   - `surface.dat`, `voxel.dat`, `tables.dat`
   - `tiles000.art` … `tiles017.art`

Filenames may be any consistent case (all-lowercase is fine — the engine
retries a lowercase variant when looking up `BLOOD.RFF` etc.). iOS is a
case-sensitive filesystem, so do **not** mix cases within one filename set.

Config (`blood.cfg`) and save games are written into this same Documents
folder, so they persist and are visible over file sharing.

## Touch controls (virtual gamepad)

There is no drawn overlay yet (functional, not pretty) — the regions are fixed:

- **Left side** (around lower-left): movement pad — slide your thumb up/down/
  left/right for forward / back / strafe-left / strafe-right (W/S/A/D).
- **Right side** (drag on empty space): look / turn (mouse-aim).
- **Buttons** (right side, by screen fraction):
  - Fire — far right, ~85% down
  - Jump — ~72% across, near the bottom
  - Use / Open — far right, ~58% down
  - Crouch — ~72% across, ~64% down
  - Next weapon — top-right corner
- A single tap also moves the menu cursor and clicks, so menus are navigable.

Bindings follow Blood's defaults; if you rebind keys in-game the buttons still
press the same physical keys (W/A/S/D/Space/E/LCtrl/'). Look sensitivity is set
by `IOS_LOOK_SENS` in `source/build/src/sdlayer.cpp`.

## What this build does / doesn't do

- Software (8-bit classic) renderer only — no OpenGL/Polymost.
- No multiplayer, no startup window, no GTK.
- Optional audio codecs (FLAC/Vorbis/XMP) are disabled in this first build.
