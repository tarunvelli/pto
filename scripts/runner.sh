#!/bin/bash

WORK_DIR=/pipeline/source
cd $WORK_DIR

CHOICE=$1

case $CHOICE in
# use rake option to run the rake tasks (namespace:task_name)
# Eg: rake db:migrate
rake)
  CMD="RAILS_ENV=${RAILS_ENV} bundle exec rake ${@:2}"
  echo "Running command '${CMD}' ..."
  eval $CMD
  ;;
# use console option to run the commands on rails console
# Eg: rails runner '"puts User.count; STDOUT.flush"'
console)
  CMD="bundle exec rails runner -e ${RAILS_ENV} ${@:2}"
  echo "Running command '${CMD}' ..."
  eval $CMD
  ;;
# use bin option to run the linux binary commands
# Eg: date, ps aux etc
bin)
  CMD="${@:2}"
  echo "Running command '${CMD}' ..."
  eval $CMD
  ;;
*)
  echo "Invalid option!";;
esac
