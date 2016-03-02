#!/bin/bash
docker run -d -p 3306:3306 boris/mariadb
docker run -d -p 6379:6379 boris/redis
docker run -tiP -v `pwd`:/app boris/perkinsci-dev:1.0
