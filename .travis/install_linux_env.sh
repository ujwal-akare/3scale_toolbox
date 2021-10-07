#!/bin/bash

set -ev

bundle config --local set path 'vendor/bundle'
case "${TRAVIS_CPU_ARCH}" in
  ppc64le) bundle lock --add-platform powerpc64le-linux;;
    s390x) bundle lock --add-platform s390x-linux;;
esac
bundle install --jobs=3 --retry=3
