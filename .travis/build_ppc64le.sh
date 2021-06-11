#!/bin/bash

set -ev

bundle config set --local path 'vendor/bundle'
bundle install --jobs=3 --retry=3

# unit tests
bundle exec rake spec:unit

# integration tests
bundle exec rake spec:integration
