#!/bin/bash
docker --config .docker  build --build-arg version=${keepalived_version} --tag ${tag} .
docker --config .docker push ${tag}

