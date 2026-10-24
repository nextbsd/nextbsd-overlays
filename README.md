# nextbsd-overlays

Seed-once, admin-owned system configuration for NextBSD images.

These files are laid onto the image root at **build time** by the image
assembler (`nextbsd/build.sh`) and the nextbsd-userland CI image assembly.
They are deliberately **not** owned by any package, so `pkg upgrade` never
touches them — once a system is installed, the administrator owns them
(accounts, SSH config, PAM stacks, mounts, …).

## Layout

- `rootfs/` — copied onto the image root: `cp -R rootfs/. "$RF"/`
  (`private/etc/*` account + service config, `pam.d/*`, and the
  `boot/loader.conf.d/nextbsd.conf` loader fragment)
- `iso/` — reserved for the live-ISO boot layer (currently inline in
  `nextbsd/build.sh`; to be migrated here)

`seed.sh <destroot>` is an only-if-absent variant for a future first-boot
seed onto an already-populated system; the image build uses a plain `cp -R`.

The overlay may hold symlinks; git stores them as links and both `cp -R` and
`seed.sh` copy them as links, never following them (their targets usually
belong to a package). Git cannot store an empty directory, so the overlay has
none.

## Display-server configuration (E25)

The libraries in nextbsd-displayserver-support read their configuration from
`/etc` (nextbsd-overlays#26):

- **`/etc/fonts`** — fontconfig's `fonts.conf` and `conf.d/`, exactly as the
  fontconfig 2.18.3 build in nextbsd-displayserver-support generates them
  (its CI log prints both). Fonts come from `/System/Library/Fonts`,
  `/Local/Library/Fonts`, `/Network/Library/Fonts`, `~/Library/Fonts`, then
  `/usr/X11/share/fonts`; the system cache is `/var/cache/fontconfig`.
  Each `conf.d/NN-*.conf` is a symlink to the template of the same name in
  `/usr/share/fontconfig/conf.avail`, the 23 upstream enables by default.
  The links are absolute: fontconfig's own install makes them relative
  (`../../../usr/share/...`), which on NextBSD would resolve from
  `/private/etc/fonts/conf.d` to `/private/usr/share` and dangle. To enable
  or disable a rule, add or remove its link; local rules go in
  `/etc/fonts/local.conf` (read through `51-local.conf`).
- **`/etc/xkb`** — libxkbcommon's extra include path, searched before
  `/usr/share/X11/xkb` for local keymap additions (`rules/`, `symbols/`, ...).
- **`/etc/libinput`** — libinput's `local-overrides.quirks`.

`/etc/xkb` and `/etc/libinput` are not shipped: both are optional override
locations that the libraries skip silently when absent, and git cannot store
an empty directory (a placeholder file would end up in every admin's `/etc`).
Create them when you need an override.

The font cache is built by the `org.nextbsd.fc-cache` launchd job, which
ships with fc-cache in nextbsd-displayserver-support
(`/System/Library/LaunchDaemons`, like cupsd's job in
nextbsd-printing-support), not here: `/System` is package-owned, and the
job must be present exactly when fc-cache is. fc-cache creates
`/var/cache/fontconfig` (0755, root) itself, so the overlay ships no `/var`.

## Why a separate repo

Config that ships inside a package gets overwritten on upgrade — NextBSD's
`pkg` marks nothing `@config`, so there is no `.pkgnew` and local edits are
lost. Pulling the user-editable `/etc` out of the package and seeding it from
here means an upgrade can never clobber a user's configuration.

Plan / rationale: https://pkgdemon.github.io/nextbsd-overlays-plan.html
