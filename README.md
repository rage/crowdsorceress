# README

## Setup for development
1. Clone this repository
2. Download submodules with `git submodule update --init --recursive`
3. Run `docker-compose build` for Docker container setup
4. Run ngrok with `./ngrok http 3000`
5. Copy the URL from ngrok to app/jobs/exercise_verifier_job.rb line 62 as 'notify' parameter
6. Run `docker-compose up`[*](http://i.imgur.com/9D3Hgti.jpg)
7. Run tests in another terminal tab with `docker-compose exec web bin/rails spec`
8. Testing POST is possible with `curl` or through frontend [Crowdsorcerer](https://github.com/rage/crowdsorcerer)

![It just works](http://i.imgur.com/mODaElx.jpg)