#!/usr/bin/env bash
set -o errexit
bundle install
mkdir -p storage log
./bin/rails assets:precompile
./bin/rails db:create db:schema:load:primary db:schema:load:queue db:schema:load:cache db:schema:load:cable
