# Perkins (rework!)

### A travis compatible minimal CI solution built in ruby

### Deploy

The server will work with RVM with ruby 2.2.2

    cap production deploy:check
  
    cap production deploy

the deploy will start puma server and sidekiq instance

The webserver is puma. to configure it just run

    cap production puma:config
  
    cap production puma:nginx_config

### Env config

In production add the following env variables to your /etc/environment

    export GITHUB_CLIENT_ID=xxx
    export GITHUB_SECRET=xxx
    export ACCESS_TOKEN=xxx
    export LOGIN=xxx
    export RACK_ENV=xxx
    export ENDPOINT=http://ci.xx.xx
    export PORT=80,
    export WORKING_DIR=/tmp
    export SECRET_KEY_BASE=xxxx

In development use the .env file