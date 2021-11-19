#!/bin/bash

set -e


SSH_USER=root
SSH_HOST=138.68.4.229
SSH_TARGET=$SSH_USER@$SSH_HOST

export DOCKER_HOST=ssh://$SSH_TARGET

# Begin Functions

connect () {
  local OPTIND

  CONTAINER=${1}

  docker exec -it "$CONTAINER" sh
}

down () {
  docker-compose down $@
}

logs () {
  docker-compose logs $@
}

ps () {
  docker-compose ps
}

pull () {
  local OPTIND

  while getopts "fp" option; do
    case "$option" in
      f) pull_foundry;;
      p) pull_proxy;;
    esac
  done
}

pull_foundry () {
  scp -r $SSH_TARGET:/opt/foundry-ian foundry-ian/foundry
  scp -r $SSH_TARGET:/opt/foundry-nick foundry-nick/foundry
}

pull_proxy () {
  scp -r $SSH_TARGET:/opt/caddy/data caddy/
}

push () {
  local OPTIND

  while getopts "cfp-:" option; do
    case "$option" in
      -)
        if [ "$OPTARG" == "all" ]; then
          push_caddy
          push_foundry
          push_proxy
        fi
        ;;
      c) push_caddy;;
      f) push_foundry;;
      p) push_proxy;;
    esac
  done
}

push_foundry () {
  scp -r foundry-flora/foundry/ $SSH_TARGET:/opt/foundry-flora/
  scp -r foundry-ian/foundry/ $SSH_TARGET:/opt/foundry-ian/
}

push_caddy () {
  ssh $SSH_TARGET "mkdir -p /opt/caddy"
  scp Caddyfile $SSH_TARGET:/opt/caddy
}

push_proxy () {
  ssh $SSH_TARGET "mkdir -p /opt/caddy/data"
  scp -r caddy/data $SSH_TARGET:/opt/caddy
}

recreate () {
  docker-compose up      \
    --force-recreate     \
    --renew-anon-volumes \
    --detach             \
    $@
}

restart () {
  docker-compose restart $@
}

rm () {
  docker-compose rm -sv $@
}

start () {
  docker-compose start $@
}

stop () {
  docker-compose stop $@
}

up () {
  docker-compose up -d $@
}

# Begin Script

COMMAND="$1"
shift

case "$COMMAND" in
  connect) connect $@;;
  compose) docker-compose $@;;
  deploy)
    push --all
    up
    ;;
  down) down $@;;
  logs) logs $@;;
  ps) ps;;
  pull)
    pull $@
    ;;
  push)
    push $@
    ;;
  recreate) recreate $@;;
  restart) restart $@;;
  rm) rm $@;;
  start) start $@;;
  stop) stop $@;;
  up) up $@;;
esac
