# Lokalise + Github APIs

You will create a simple web app with one model and controller. No effort is required on frontend, just
the most basic CRUD is enough.
You will be interacting with two different services through their API or command-line tools:
 - Lokalise, a web service for translations management
 - GitHub, a web service for versioning code and other text-based content
The only model in the app is Tool with fields:
 - name [string]
 - language [string] (2-letter language code)
 - json_spec [json]
Controller for this model should implement two actions

## Overview

This application uses Rails version 6.1.5, Ruby version 2.7.2.

This application contains following endpoints:

 - `/create` - When a tool is created, fetches the JSON tool spec from GitHub using the name convention described in Background.
 - `/update` - Updates Tool translations and creates PR

There is one model:

 - `Tool` - stores tool information: `name`, `language`, `json_spec`

## Local setup

* Install Ruby version 2.7.2: `rvm install 2.7.2`
* Bundle: `bundle install`
* Run migration: `rails db:migrate`
* Run server: `rails server`

## Usage

### Create a Tool

- Create JSON spec in `https://github.com/feruzoripov/dev_challenge_json_specs`. (Merge PR or push on master branch)
- it stores newly created spec in Tool models, and generates files with translations keys in `/locales`

### Update Tool

There were problems when integrating Lokalise gem, so I skipped this part. In order to update existing translation keys, you need to make changes in the file located in `/locales` and make a POST request to `/update` endpoint with following params:
 - name:string
 - language:string
 - master:boolean (true or false to define master file)
After making request, it will create PR in `https://github.com/feruzoripov/dev_challenge_json_specs` with updated keys. Once merged, it will update tool in the database.


NOTE: Github token is needed to create PR. Also, configuration of webhooks in the repo is needed and ngrok for making local server accessible.
