# README

Simple Benchmark for Metka gem

## Setup

- run `bundle install` to install required gems
- configure your database connection with `config/database.yml` as you prefer
- create your database with `bundle exec rails db:create` if you haven't decided to use present database on previous step
- run all migrations with `bundle exec rails db:migrate`

## Usage

Simply run `$ bundle exec rake bench:all` to run all available benchmarks in order
