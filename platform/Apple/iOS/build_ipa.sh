#!/usr/bin/env bash
#
# Build an unsigned NBlood.ipa for arm64 iOS (sideload via AltStore/LiveContainer).
#
# Pipeline:
#   1. make PLATFORM=IOS nblood-ios        -> libnblood.a (all engine+game objects)
#   2. link with libSDL2.a + libSDL2main.a + iOS frameworks -> NBlood (Mach-O)
#   3. assemble NBlood.app (executable + Info.plist + PkgInfo)
#   4. Payload/NBlood.app -> NBlood.ipa (plain zip; no codesign, AltStore re-signs)
#
# No xcodebuild / Xcode IDE required -- only the iphoneos clang toolchain.
set -euo pipefail

IOS_MIN="${IOS_MIN:-16.0}"
JOBS="${JOBS:-8}"

# Repo root = two levels up from this script (platform/Apple/iOS/).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SDL="$SCRIPT_DIR/SDL2"
OUT="${OUT:-$REPO/platform/Apple/iOS/build}"

SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
CLANGXX="$(xcrun --sdk iphoneos --find clang++)"

echo ">> Repo:    $REPO"
echo ">> SDK:     $SDK"
echo ">> Output:  $OUT"

# --- 1. Build the static library --------------------------------------------
echo ">> [1/4] Building libnblood.a ..."
make -C "$REPO" PLATFORM=IOS nblood-ios -j"$JOBS"

# --- 2. Link the executable -------------------------------------------------
echo ">> [2/4] Linking NBlood executable ..."
mkdir -p "$OUT"
"$CLANGXX" \
    -target arm64-apple-ios"$IOS_MIN" \
    -isysroot "$SDK" \
    -miphoneos-version-min="$IOS_MIN" \
    -o "$OUT/NBlood" \
    -Wl,-force_load,"$REPO/libnblood.a" \
    "$SDL/lib/libSDL2main.a" \
    "$SDL/lib/libSDL2.a" \
    -liconv \
    -framework Foundation \
    -framework UIKit \
    -framework CoreGraphics \
    -framework QuartzCore \
    -framework CoreAudio \
    -framework AudioToolbox \
    -framework AVFoundation \
    -framework CoreMotion \
    -framework GameController \
    -framework CoreBluetooth \
    -framework OpenGLES \
    -framework Metal \
    -framework CoreHaptics \
    -framework ImageIO \
    -framework CoreVideo

echo ">> Linked: $(cd "$OUT" && lipo -info NBlood)"

# --- 3. Assemble the .app bundle --------------------------------------------
echo ">> [3/4] Assembling NBlood.app ..."
APP="$OUT/NBlood.app"
rm -rf "$APP"
mkdir -p "$APP"
cp "$OUT/NBlood" "$APP/NBlood"
chmod +x "$APP/NBlood"
cp "$SCRIPT_DIR/Info.plist" "$APP/Info.plist"
printf 'APPL????' > "$APP/PkgInfo"

# Bundle NBlood's own resource pack (engine/menu assets). This is NBlood's, not
# the user's copyrighted Blood data -- BLOOD.RFF etc. go in Documents instead.
if [ -f "$REPO/nblood.pk3" ]; then
    cp "$REPO/nblood.pk3" "$APP/nblood.pk3"
    echo ">> Bundled nblood.pk3 ($(du -h "$REPO/nblood.pk3" | cut -f1))"
else
    echo ">> WARNING: $REPO/nblood.pk3 not found -- the app will not reach the menu without it"
fi

# Optional app icon, if present in the asset catalog source.
if [ -f "$SCRIPT_DIR/AppIcon60x60@2x.png" ]; then
    cp "$SCRIPT_DIR/AppIcon60x60@2x.png" "$APP/"
fi

# --- 4. Package the IPA -----------------------------------------------------
echo ">> [4/4] Packaging NBlood.ipa ..."
PAYLOAD="$OUT/Payload"
rm -rf "$PAYLOAD" "$OUT/NBlood.ipa"
mkdir -p "$PAYLOAD"
cp -R "$APP" "$PAYLOAD/"
( cd "$OUT" && zip -qr -X NBlood.ipa Payload )
rm -rf "$PAYLOAD"

echo ""
echo ">> DONE: $OUT/NBlood.ipa"
ls -la "$OUT/NBlood.ipa"
