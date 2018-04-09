# Crowdsorceress

[![Build Status](https://travis-ci.org/rage/crowdsorceress.svg?branch=master)](https://travis-ci.org/rage/crowdsorceress)

Crowdsorceress is a backend for [Crowdsorcerer](https://github.com/rage/crowdsorcerer), a tool for crowdsourcing programming exercises for a CS1 course.
After creating an exercise with the tool, it is sent here. Crowdsorceress generates two projects for the exercise: one for the template and one for the model solution.
It then sends them both to TMC Sandbox, which checks that they both compile and that the tests pass for the model solution. Crowdsorceress sends the received results back to the frontend.

Crowdsorceress also takes care of the database and saves all submitted exercises there.

Created with Ruby on Rails.

## Setup for development

Use this setup guide to get the project up and running on your local machine for development and testing purposes.

### Prerequisites
- [Ruby on Rails](http://guides.rubyonrails.org/getting_started.html#guide-assumptions)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [ngrok](https://ngrok.com/download)
- The system is designed to be embedded in an online course material. This is why one needs a TMC user account to be able to use it.
You can create an account [here](https://tmc.mooc.fi/user/new).

### Setup

1. Clone this repository
2. Download submodules and build tmc-langs with `bin/pre_setup`
3. Run `docker-compose build` for Docker container setup
4. Setup database with `docker-compose run --service-ports web bin/rails db:setup`
    1. To use the admin features, set the user associated with your TMC account as an admin by using [the rails console](http://guides.rubyonrails.org/command_line.html#rails-console)

### Usage

1. Go to the directory in which you installed ngrok and run `./ngrok http 3000`
    1. ngrok then gives you the url where sandbox results are sent. Copy and paste it to the environment variable BASE_URL
2. Run `docker-compose up`
3. Submit exercises and peer reviews through the frontend: [Crowdsorcerer](https://github.com/rage/crowdsorcerer)


### Running the tests

Run tests with `docker-compose exec web bin/rails spec` while the docker container is running.

---

### Old setup guide (with the memes)

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
