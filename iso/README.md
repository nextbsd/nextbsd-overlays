# iso/

Reserved for the live-ISO boot overlay (`cp -R iso/. "$ISOROOT"/`): the
mfsroot `/init` rescue-pivot script and the live `loader.conf`.

These currently live inline as heredocs in `nextbsd/build.sh`; they will be
migrated here so the live-boot layer is centrally defined alongside `rootfs/`.
