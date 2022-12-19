#!/usr/bin/env bash
if [ -f "getenv.sh" ]; then
    source getenv.sh
fi
eval_cmd_base="docker push $PROJECT_DOCKER_FULL_PATH"
# eval "$eval_cmd_base"


# eval_cmd="docker buildx build --push --platform linux/arm64/v8 --tag $PROJECT_DOCKER_FULL_PATH ."
#eval_cmd="docker buildx build --push --platform linux/amd64,linux/arm64/v8 --tag $PROJECT_DOCKER_FULL_PATH ."

# AMD64
eval_cmd_amd="docker push ${PROJECT_DOCKER_FULL_PATH}-amd64"
eval "$eval_cmd_amd"

# ARM32V7
eval_cmd_arm32v7="docker push ${PROJECT_DOCKER_FULL_PATH}-arm32v7"
eval "$eval_cmd_arm32v7"

# ARM64V8
eval_cmd_arm64v8="docker push ${PROJECT_DOCKER_FULL_PATH}-arm64v8"
eval "$eval_cmd_arm64v8"

eval_manifest_amend="docker manifest create \
${PROJECT_DOCKER_FULL_PATH} \
--amend ${PROJECT_DOCKER_FULL_PATH}-amd64 \
--amend ${PROJECT_DOCKER_FULL_PATH}-arm32v7 \
--amend ${PROJECT_DOCKER_FULL_PATH}-arm64v8"

eval "$eval_manifest_amend"

eval_manifest_push="docker manifest push $PROJECT_DOCKER_FULL_PATH"

eval "$eval_manifest_push"

