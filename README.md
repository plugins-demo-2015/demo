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
vagrant up tester-1 tester-2 tester-3
./local_swarm_manager.sh
```

```
cd app
env DOCKER_HOST=tcp://localhost:2375 docker-compose up -d
```
