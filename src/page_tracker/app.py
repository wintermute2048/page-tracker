"""Simple webpage with a visit counter, which is managed by a redis
database"""
import os
from functools import cache

from flask import Flask
from redis import Redis, RedisError

app = Flask(__name__)


@app.get("/")
def index():
    """Main webpage featuring a visit counter."""
    try:
        page_views = redis().incr("page_views")
    except RedisError:
        app.logger.exception("Redis error")
        return "Sorry, something went wrong \N{pensive face}", 500

    return f"This page has been seen {page_views} times."


@cache
def redis():
    """This function allows creation of a mock for testing.
    Cache makes this to a singleton."""
    return Redis.from_url(os.getenv("REDIS_URL", "redis://localhost:6379"))
