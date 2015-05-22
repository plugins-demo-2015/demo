> The most extraordinary and flabbergastingly brilliant demonstration of Docker plugins in the whole wide world.
## Setup

```
./bootstrap.sh
./build.sh
vagrant suspend builder
./setup_test_vms.sh
```

## Rebuild

```
vagrant up builder
./build.sh
vagrant suspend builder
```

## Compose

```
./local_swarm_manager.sh
```

```
cd app
env DOCKER_HOST=tcp://localhost:2375 docker-compose up -d
```
>>>>>>> 614744b00b2ca780293883e1bb3e8f93fe5d7368
