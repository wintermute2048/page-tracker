FROM python:3.11.4-slim-bullseye AS builder

RUN apt-get update && \
    apt-get upgrade --yes

RUN useradd --create-home user
USER user
WORKDIR /home/user

ENV VIRTUALENV=/home/user/venv
RUN python3 -m venv $VIRTUALENV
ENV PATH="$VIRTUALENV/bin:$PATH"

COPY --chown=user pyproject.toml constraints.txt ./
RUN python -m pip install --upgrade pip setuptools && \
    python -m pip install --no-cache-dir -c constraints.txt ".[dev]"

COPY --chown=user src/ src/
COPY --chown=user test/ test/

RUN python -m pip install . -c constraints.txt && \
    python -m pytest test/unit/ && \
    python -m flake8 src/ && \
    python -m isort src/ --check && \
    python -m black src/ --check --quiet && \
    python -m pylint src/ && \
    python -m bandit -r src/ --quiet && \
    python -m pip wheel --wheel-dir dist/ . -c constraints.txt


FROM python:3.11.4-slim-bullseye

RUN apt-get update && \
    apt-get upgrade --yes

RUN useradd --create-home user
USER user
WORKDIR /home/user

ENV VIRTUALENV=/home/user/venv
RUN python3 -m venv $VIRTUALENV
ENV PATH="$VIRTUALENV/bin:$PATH"

COPY --from=builder /home/user/dist/page_tracker*.whl /home/user/

RUN python -m pip install --upgrade pip setuptools && \
    python -m pip install --no-cache-dir page_tracker*.whl

CMD ["flask", "--app", "page_tracker.app", "run", \
     "--host", "0.0.0.0", "--port", "5000"]