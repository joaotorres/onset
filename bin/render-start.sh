#!/usr/bin/env bash
set -o errexit
./bin/rails db:create
./bin/rails server