#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install

echo "Database URL: $DATABASE_URL"

# only run this if WEB is set
if [ ! -z "$WEB" ]; then
  bundle exec rake assets:precompile
  bundle exec rake assets:clean
  bundle exec rake db:migrate
fi
