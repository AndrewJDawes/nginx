#!/usr/bin/env bash
if [ -f "getenv.sh" ]; then
    source getenv.sh
fi
eval_cmd="docker pull $PROJECT_DOCKER_FULL_PATH"
eval "$eval_cmd"