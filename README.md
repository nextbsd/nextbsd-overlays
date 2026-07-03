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

## Why a separate repo

Config that ships inside a package gets overwritten on upgrade — NextBSD's
`pkg` marks nothing `@config`, so there is no `.pkgnew` and local edits are
lost. Pulling the user-editable `/etc` out of the package and seeding it from
here means an upgrade can never clobber a user's configuration.

Plan / rationale: https://pkgdemon.github.io/nextbsd-overlays-plan.html
