#!/bin/bash
set -e

./bin/thrust ./bin/rails db:prepare
./bin/thrust ./bin/rails assets:precompile
./bin/thrust ./bin/rails server -p 3000