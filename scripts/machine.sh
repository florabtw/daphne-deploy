#!/bin/bash

set -e

MACHINE_NAME=nikki

# Begin Functions

connect () {
  local OPTIND

  CONTAINER=${1}

  docker exec -it "$CONTAINER" bash
}

down () {
  docker-compose down
}

logs () {
  docker-compose logs $@
}

pull () {
  local OPTIND

  while getopts "a" option; do
    case "$option" in
      a) pull_acme;;
    esac
  done
}

pull_acme () {
  docker-machine scp $MACHINE_NAME:/opt/traefik/acme.json acme.json
}

push () {
  local OPTIND

  while getopts "a-:" option; do
    case "$option" in
      -)
        if [ "$OPTARG" == "all" ]; then
          push_acme
        fi
        ;;
      a) push_acme;;
    esac
  done
}

push_acme () {
  docker-machine ssh $MACHINE_NAME "mkdir -p /opt/traefik"
  docker-machine scp acme.json $MACHINE_NAME:/opt/traefik/acme.json
  docker-machine ssh $MACHINE_NAME "chmod 600 /opt/traefik/acme.json"
}

restart () {
  docker-compose restart $@
}

recreate () {
  docker-compose up      \
    --force-recreate     \
    --renew-anon-volumes \
    --detach             \
    $@
}

use_machine () {
  eval $(docker-machine env $MACHINE_NAME)
}

up () {
  docker-compose up -d $@
}

# Begin Script

COMMAND="$1"
shift

case "$COMMAND" in
  connect)
    use_machine
    connect $@
    ;;
  deploy)
    push --all
    use_machine
    up
    ;;
  down)
    use_machine
    down
    ;;
  logs)
    use_machine
    logs $@
    ;;
  pull)
    pull $@
    ;;
  push)
    push $@
    ;;
  recreate)
    use_machine
    recreate $@
    ;;
  restart)
    use_machine
    restart $@
    ;;
  up)
    use_machine
    up $@
    ;;
esac
