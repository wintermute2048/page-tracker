Steps
- [x] Install docker desktop
- [x] virtual environment
```
py -m venv venv --prompt page-tracker
.\venv\Scripts\activate
py -m pip install --upgrade pip
```
- [x] Create pyproject.toml
- [x] Install package in editable mode and list version to constraints.txt
```
py -m pip install --editable .
py -m pip freeze --exclude-editable > constraints.txt
```
- [x] Create redis docker
    - create docker network
    - connect with (ephemeral) client
```
docker run -d --name redis-server redis
docker network create page-tracker-network
docker network ls
docker network connect page-tracker-network redis-server
docker run --rm -it --name redis-client --network page-tracker-network redis redis-cli -h redis-server

# restart server and add port mapping
docker stop redis-server
docker rm redis-server
docker run -d --name redis-server -p 6379:6379 redis
docker inspect redis-server
```
It has ip address `172.17.0.3`

- [x] write flask code and try it
```
flask --app page_tracker.app run
```
- [x] Add pytest as optional dependency and install it to venv
- [x] write unit test and run it `py -m pytest -v test/unit`
- [x] add integration test
    - add pytest-timeout to optional-dependencies and write test
- [x] add end-to-end test
    - add requests to optional-dependencies and write test
    - make redis and flask url configurable via environment variables (or argument via `pytest_addoption` hook)
    - Finally run test with `py -m pytest -v .\test\e2e\ --flask-url http://127.0.0.1:5000 --redis-url redis://127.0.0.1:6379`
- [x] add static code analysis tools
```
py -m black src/ --diff --color # formatting
py -m isort src/ --check # sorting inputs
py -m flake8 src/ # PEP 8 style
py -m bandit -r src/ # security issues
```
- [x] write Dockerfile and build.
    - make multi-stage Dockerfile
    - initialize git and use its hash to tag the docker image
```
docker build -t page-tracker:$(git rev-parse --short HEAD) .
```

- push it to Docker Hub
```
docker login -u wintermute2048
docker tag page-tracker:43fc387 wintermute2048/page-tracker:43fc387
#docker images # see images
#docker rmi # remove a tag
#docker image rm repo:tag # remove image
docker push wintermute2048/page-tracker:43fc387
docker tag page-tracker:latest wintermute2048/page-tracker:latest
docker push wintermute2048/page-tracker:latest
```

- run the uploaded docker image
```
docker run -p 80:5000 --name web-service wintermute2048/page-tracker
# ctrl-c
docker ps -a
docker rm <CONTAINER_ID>
```

- create mount for redis container
```
docker volume create redis-volume
docker run -d -v redis-volume:/data --network page-tracker-network --name redis-service redis:7.0.10-bullseye
docker run -d -p 80:5000 -e REDIS_URL=redis://redis-service:6379 --network page-tracker-network --name web-service wintermute2048/page-tracker
```

- create `docker-compose` file and move current project to subfolder `web/`, which requires to recreate `venv`, then delete all current docker containers, networks and volumes.

- add gunicorn as wsgi server, add entry-point to docker compose and rebuild and start with `docker compose up -d --build`

Now I should be able to run E2E tests again.

- add test-service to docker compose and run it
```
docker compose --profile testing up -d
docker compose ps -a # see that test exited
docker compose logs test-service
```

- create github workflow