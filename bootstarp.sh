DOCKER_FORK=${DOCKER_FORK:-"https://github.com/squaremo/docker"}
DOCKER_FORK_BRANCH=${DOCKER_FORK_BRANCH:-"network_extensions"}

WEAVE_FORK=${WEAVE_FORK:-"https://github.com/squaremo/weave"}
WEAVE_FORK_BRANCH=${WEAVE_FORK_BRANCH:-"plugin_ipam"}

cd build
git clone --depth=10 --branch=$DOCKER_FORK_BRANCH $DOCKER_FORK docker
git clone --depth=10 --branch=$WEAVE_FORK_BRANCH $WEAVE_FORK weave
vagrant up
