# Nikki

This repository is to help the maintainer, [Nick Pierson](https://nick.exposed),
deploy multiple services to a particular DigitalOcean Droplet.

## Dependencies

In order to deploy, you will need to reveal the secrets in the repo.
You will need your GPG key.
You will also need to be added as a member of git secret.

### Reveal secrets

```
git secret reveal
```

### Install Dependencies

```
yarn
```

## Tools

There is a script located at `./scripts/machine.sh` that has several commands
that help manage a remote docker machine.

Here is a list of commands:

### connect

This command allows you to connect to a bash instance on any docker container.

Example:

```
./scripts/machine.sh connect soundoftext-web
```

### down

This command is the equivalent of `docker-compose down`. This will stop and
remove all docker containers.

Example:

```
./scripts/machine.sh down
```

### logs

This command is the equivalent of `docker-compose logs`. It takes all the same
arguments. This will display logs from all containers.

Example:

```
./scripts/machine.sh logs -f # soundoftext-web
```

### ps

This command will list running docker containers.

Example:

```
./scripts/machine.sh ps
```

### pull

This command is for copying files from the remote machine, in order to be pushed
again later (possibly to a different machine).

Supported flags:

```
./scripts/machine.sh pull -b # pulls blog content
./scripts/machine.sh pull -p # pulls proxy data (acme.json)
./scripts/machine.sh pull -s # pulls sound of text database
```

### push

This command is for pushing files to the remote machine, before starting the
containers. This would be used on initial deployment, or before a
[restart](#restart) or [recreate](#recreate).

Examples:

```
./scripts/machine.sh push -b # pushes blog content
./scripts/machine.sh push -p # pushes proxy data (acme.json)
./scripts/machine.sh push -s # pushes sound of text database
```

### recreate

This command force recreates docker containers and renews anonymous volumes. You
would run this command after doing a push.

Example:

```
./scripts/machine.sh -e staging recreate
```

### restart

This command is the equivalent of `docker-compose restart`. It takes all the
same arguments.

Examples:

```
./scripts/machine.sh restart # restart all containers
./scripts/machine.sh restart soundoftext-web # restarts soundoftext-web
```

### up

This command is the equivalent of `docker-compose up` and takes all the same
arguments.

Example:

```
./scripts/machine.sh up
```

## Deploy (first time)

If you want to deploy all instances to a new machine (or migrate), you can
follow these steps:

### Provision new Docker Machine

This part is up to you, but for me, I have a script at
`~/.scripts/create-droplet.sh`

### (Optional) Pull Data from Previous Machine

Edit `/.scripts/machine.sh` such that `MACHINE_NAME` points to the old machine.
Then run:

```
./scripts/machine pull -p # pulls acme.json
./scripts/machine pull -b # pulls blog content
./scripts/machine pull -s # pulls sound of text database
```

### Push Data to New Machine

Edit `/.scripts/machine.sh` such that `MACHINE_NAME` points to the new machine.
Then run:

```
./scripts/machine push -p # pushes acme.json
./scripts/machine push -b # optional
./scripts/machine push -s # optional 
```

### Deploy Sites

Now, spin up all the containers:

```
./scripts/machine.sh up
```
