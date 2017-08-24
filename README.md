[![Build Status](https://travis-ci.org/rage/crowdsorceress.svg?branch=master)](https://travis-ci.org/rage/crowdsorceress)

# README

## Setup for development
1. Clone this repository
2. Download submodules and build tmc-langs with `bin/pre_setup`
3. Run `docker-compose build` for Docker container setup
4. Run ngrok with `./ngrok http 3000`
5. Add the URL from ngrok to env variable BASE_URL
6. Run `docker-compose up`[*](http://i.imgur.com/9D3Hgti.jpg)
7. Run tests in another terminal tab with `docker-compose exec web bin/rails spec`
8. Submit exercises and peer reviews through frontend [Crowdsorcerer](https://github.com/rage/crowdsorcerer)

![It just works](http://i.imgur.com/mODaElx.jpg)

[Crowdsorceress is now on the Internet!](https://crowdsorcerer.testmycode.io)
Test your admin privileges today!
