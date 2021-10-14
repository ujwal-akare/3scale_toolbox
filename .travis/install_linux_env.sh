#!/bin/bash

set -ev

bundle config --local set path 'vendor/bundle'
bundle install --jobs=3 --retry=3
