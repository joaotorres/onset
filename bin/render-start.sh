#!/usr/bin/env bash
set -o errexit
./bin/rails db:create db:schema:load
./bin/rails server