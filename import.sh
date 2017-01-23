#!/usr/bin/env sh

MAKE=${MAKE:-make}
set -eu

rm -rf internal/*
find . -type l -not -path './.git/*' -exec rm {} \;
curl -sL https://github.com/jemalloc/jemalloc/releases/download/4.4.0/jemalloc-4.4.0.tar.bz2 | tar jxf - -C internal --strip-components=1

# You need to manually run the following code.
# on OSX:
# (cd internal && MACOSX_DEPLOYMENT_TARGET=10.9 ./configure --enable-prof --with-jemalloc-prefix='')
# <compare "Build parameters" in internal/Makefile to cgo flags in cgo_flags.go> and adjust the latter.
# rm -r darwin_includes
# git clean -Xn -- internal/include/jemalloc | sed 's/.* //' | xargs -I % rsync -R % darwin_includes/
#
# on Linux with glibc:
# (cd internal && echo 'je_cv_madv_free=no' > config.cache && ./configure --enable-prof -C && rm config.cache)
# <compare "Build parameters" in internal/Makefile to cgo flags in cgo_flags.go> and adjust the latter.
# rm -r linux_glibc_includes
# git clean -Xn -- internal/include/jemalloc | sed 's/.* //' | xargs -I % rsync -R % linux_glibc_includes/
#
# on Linux with musl:
# (cd internal && echo 'je_cv_madv_free=no' > config.cache && ./configure --enable-prof -C && rm config.cache)
# <compare "Build parameters" in internal/Makefile to cgo flags in cgo_flags.go> and adjust the latter.
# rm -r linux_musl_includes
# git clean -Xn -- internal/include/jemalloc | sed 's/.* //' | xargs -I % rsync -R % linux_musl_includes/
#
# on FreeBSD:
# (cd internal && ./configure --enable-prof)
# <compare "Build parameters" in internal/Makefile to cgo flags in cgo_flags.go> and adjust the latter.
# rm -r freebsd_includes
# git clean -Xn -- internal/include/jemalloc | sed 's/.* //' | xargs -I % rsync -R % freebsd_includes/

# symlink so cgo compiles them
for source_file in $($MAKE sources); do
  ln -sf "$source_file" .
done

# restore the repo to what it would look like when first cloned.
# comment this line out while updating upstream.
git clean -dxf
