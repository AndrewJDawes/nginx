#!/usr/bin/env bash
if [ -f "getenv.sh" ]; then
    source getenv.sh
fi

# INSTALL EMULATORS
docker run --privileged --rm tonistiigi/binfmt --install all

# BASE CMD
eval_cmd_base="docker build -t $PROJECT_DOCKER_FULL_PATH"
# eval_cmd_base="docker build --no-cache -t $PROJECT_DOCKER_FULL_PATH"

# SIMPLE CMD
eval_cmd_simple="$eval_cmd_base ."
# eval "$eval_cmd_simple"

# AMD64
eval_cmd_amd="${eval_cmd_base}-amd64 --build-arg ARCH=amd64/ ."
#eval_cmd_amd="docker push your-username/multiarch-example:manifest-amd64"
eval "$eval_cmd_amd"

# ARM32V7
#docker build -t your-username/multiarch-example:manifest-arm32v7 --build-arg ARCH=arm32v7/ .
# docker push your-username/multiarch-example:manifest-arm32v7
eval_cmd_arm32v7="${eval_cmd_base}-arm32v7 --build-arg ARCH=arm32v7/ ."
eval "$eval_cmd_arm32v7"


# ARM64V8
# docker build -t your-username/multiarch-example:manifest-arm64v8 --build-arg ARCH=arm64v8/ .
# docker push your-username/multiarch-example:manifest-arm64v8
eval_cmd_arm64v8="${eval_cmd_base}-arm64v8 --build-arg ARCH=arm64v8/ ."
eval "$eval_cmd_arm64v8"