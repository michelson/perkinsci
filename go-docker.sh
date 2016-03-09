#!/bin/bash
docker run -d -p 3306:3306 --name perkinsci-db boris/perkinsci-db:1.0
docker run -tiP -p 3000:3000 --name perkinsci-dev -v `pwd`:/app boris/perkinsci-dev:1.1 /bin/bash
