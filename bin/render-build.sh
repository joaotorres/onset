#!/usr/bin/env bash
set -o errexit
bundle install
mkdir -p storage log
./bin/rails assets:precompile
./bin/rails db:prepare
