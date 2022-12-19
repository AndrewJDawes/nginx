# Create buildx builder
# https://programmersought.com/article/298810034228/
# docker buildx create --use --name=mybuilder-cn --driver docker-container --driver-opt image=dockerpracticesig/buildkit:master

# Install emulators
# https://stackoverflow.com/a/70168030
# docker run --privileged --rm tonistiigi/binfmt --install all

# Build/push:
# docker buildx build \
# --push \
# --platform linux/arm/v7,linux/arm64/v8,linux/amd64 \ --tag your-username/multiarch-example:buildx-latest .

# Run:
# docker run -d -p 49160:8080 --platform linux/arm64 andrewjdawes/docker-express-hello-world:buildx-latest