#!/bin/bash -Eeu

# Added beside the compiler the base image put in /etc/ts, rather than into a
# prefix of their own, because a start-point symlinks that one directory in as
# its node_modules and node finds a package only by looking there.
#
# typescript is deliberately absent: it comes from the base image. Naming it
# here would let this image drift to a different compiler from its siblings,
# which is the thing having a base image is for.
# The base image sets NODE_COMPILE_CACHE, and npm runs here as root. Node names
# the cache directory after the uid that wrote it, so anything root puts there
# is a directory no kata can ever read: image size paid for nothing. Unsetting
# it for this one command keeps that weight out, and the warming step that
# follows, which runs as sandbox, writes the cache a kata does read.
env --unset=NODE_COMPILE_CACHE npm install --prefix /etc/ts \
  vitest \
  eslint \
  prettier \
  @eslint/js \
  @types/node \
  eslint-config-prettier \
  eslint-plugin-prettier \
  typescript-eslint

# The base image set this for what it installed; these packages are new, and a
# kata runs as sandbox.
chown -R sandbox /etc/ts
