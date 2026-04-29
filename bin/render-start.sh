#!/usr/bin/env bash
set -o errexit
./bin/rails db:prepare
./bin/rails server