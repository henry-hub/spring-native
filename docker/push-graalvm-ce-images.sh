#!/usr/bin/env bash

docker push springci/graalvm-ce:21.0-dev-java8
docker push springci/graalvm-ce:21.0-dev-java11
docker push springci/graalvm-ce:master-java8
docker push springci/graalvm-ce:master-java11