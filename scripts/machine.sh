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

ps () {
  docker-compose ps
}

pull () {
  local OPTIND

  while getopts "bp" option; do
    case "$option" in
      b) pull_blog;;
      p) pull_proxy;;
    esac
  done
}

pull_blog () {
  mkdir -p blog/content
  docker-machine scp -r $MACHINE_NAME:/opt/ghost/content/images blog/content
}

pull_proxy () {
  docker-machine scp $MACHINE_NAME:/opt/traefik/acme.json acme.json
}

push () {
  local OPTIND

  while getopts "bp-:" option; do
    case "$option" in
      -)
        if [ "$OPTARG" == "all" ]; then
          push_proxy
        fi
        ;;
      b) push_blog;;
      p) push_proxy;;
    esac
  done
}

push_blog () {
  docker-machine ssh $MACHINE_NAME "mkdir -p /opt/ghost/content"
  docker-machine scp -r blog/content/images $MACHINE_NAME:/opt/ghost/content
}

push_proxy () {
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

start () {
  docker-compose start $@
}

stop () {
  docker-compose stop $@
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
  ps)
    use_machine
    ps
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
  start)
    use_machine
    start $@
    ;;
  stop)
    use_machine
    stop $@
    ;;
  up)
    use_machine
    up $@
    ;;
esac
