#!/bin/sh
# seed.sh <destroot> — lay the rootfs overlay onto a target root, ONLY where
# each file is absent (never overwrite an admin's existing file). The image
# build uses a plain `cp -R rootfs/. "$RF"/` on a fresh root; this only-if-absent
# variant is for a future first-boot seed onto an already-populated system.
set -eu
DEST=${1:?usage: seed.sh <destroot>}
cd "$(dirname "$0")/rootfs"
find . -type f | while IFS= read -r rel; do
    rel=${rel#./}
    if [ ! -e "$DEST/$rel" ]; then
        mkdir -p "$DEST/$(dirname "$rel")"
        cp -p "$rel" "$DEST/$rel"
    fi
done
# git can't store sub-0644 modes; master.passwd must be 0600.
chmod 0600 "$DEST/private/etc/master.passwd" 2>/dev/null || true
# sudo rejects a sudoers file that is group- or world-writable; ship it 0440.
chmod 0440 "$DEST/private/etc/sudoers" 2>/dev/null || true
