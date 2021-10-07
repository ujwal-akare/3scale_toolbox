#!/bin/bash

set -ev

# unit tests
bundle exec rake spec:unit

# integration tests
bundle exec rake spec:integration
