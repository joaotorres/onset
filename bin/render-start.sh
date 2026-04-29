#!/usr/bin/env bash
set -o errexit
./bin/rails db:create
./bin/rails db:schema:load:primary db:schema:load:queue db:schema:load:cache db:schema:load:cable
./bin/rails server