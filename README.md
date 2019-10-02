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

## Deploy

Once you have fulfilled all the dependencies, simply run:

```
./scripts/machine.sh deploy
```
