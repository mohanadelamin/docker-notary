#!/usr/bin/env bash

echo "Setting notary server url to https://127.0.0.1:4443"
export DOCKER_CONTENT_TRUST_SERVER=https://127.0.0.1:4443

echo "Pulling alpine:latest"
docker pull alpine:latest

echo "Tag alpine to localhost:5000/alpine:unsigned"
docker tag alpine:latest localhost:5000/alpine:unsigned

echo "Push localhost:5000/alpine:unsigned to local registry"
docker push localhost:5000/alpine:unsigned

echo "Generate notary target key name: target-a"
export DOCKER_CONTENT_TRUST_ROOT_PASSPHRASE="rootpass123"
export DOCKER_CONTENT_TRUST_REPOSITORY_PASSPHRASE="repopass123"
docker trust key generate target-a

echo "Add target-a as trust signer for GUN localhsot:5000/alpine"
docker trust signer add --key target-a.pub target-a localhost:5000/alpine

echo "Tag alpine latest to localhost:5000/alpine:signed"
docker tag alpine:latest localhost:5000/alpine:signed

echo "Sign and push localhost:5000/alpine:signed"
docker trust sign localhost:5000/alpine:signed


echo "List available keys"
notary key list

echo "list delegations for GUN localhost:5000/alpine"
notary delegation list localhost:5000/alpine

echo "Inspect the signed image"
docker trust inspect localhost:5000/alpine:signed --pretty

echo "Inspect the unsigned image"
docker trust inspect localhost:5000/alpine:unsigned --pretty

echo "Setting DOCKER_CONTENT_TRUST=1"
export DOCKER_CONTENT_TRUST=1

echo "Try pulling the unsigned image"
docker pull localhost:5000/alpine:unsigned

echo "Try pulling the signed image"
docker pull localhost:5000/alpine:signed
