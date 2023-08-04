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
- [x] write Dockerfile and build with `docker build -t page-tracker .`
    - make multi-stage Dockerfile
- [] initialize git and use its hash to tag the docker image