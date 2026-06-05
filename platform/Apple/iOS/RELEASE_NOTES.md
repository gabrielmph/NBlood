Unsigned NBlood for iOS (arm64, iOS 16+) — sideload via AltStore / LiveContainer.

**Software renderer build.** Touch controls included (virtual gamepad).

> ⚠️ **Untested on a physical device.** This build was compiled and verified
> statically (architecture, entry point, bundle layout) but has not yet been
> run on real iOS hardware. First-launch behavior — SDL/UIKit init, game-data
> discovery, and touch input — is unverified. Treat it as experimental and
> please report what happens (and any log output) if you try it.

## Install
1. Sideload `NBlood.ipa` with AltStore (it re-signs on install).
2. Open **Files → On My iPhone → NBlood** and copy your Blood data files in:
   `blood.rff`, `gui.rff`, `sounds.rff`, `blood.ini`, `surface.dat`,
   `voxel.dat`, `tables.dat`, `tiles000.art`–`tiles017.art`.
3. Launch.

You must own a copy of Blood; no game data is included.

## Controls
Left side = move (W/A/S/D), right-side drag = look, on-screen buttons for
Fire / Jump / Use / Crouch / Next-weapon. See `platform/Apple/iOS/README.md`.

Built from branch `ios-port` with `platform/Apple/iOS/build_ipa.sh`.
