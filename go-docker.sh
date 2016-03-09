#!/bin/bash
docker run -d -p 3306:3306 boris/perkinsci-db:1.0
docker run -tiP -p 3000:3000 -v `pwd`:/app boris/perkinsci-dev:1.1 /bin/bash
