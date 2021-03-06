# jira-team-metrics

[![Build Status](https://travis-ci.org/jbrunton/jira-team-metrics.svg?branch=master)](https://travis-ci.org/jbrunton/jira-team-metrics)
[![Maintainability](https://api.codeclimate.com/v1/badges/37fd2ef941e590fbb33d/maintainability)](https://codeclimate.com/github/jbrunton/jira-team-metrics/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/37fd2ef941e590fbb33d/test_coverage)](https://codeclimate.com/github/jbrunton/jira-team-metrics/test_coverage)

A reporting tool for visualising flow metrics for JIRA projects.

## Getting Started

To quickly try out the app, clone and install dependencies:

    git clone https://github.com/jbrunton/jira-team-metrics.git
    cd jira-team-metrics
    bundle install

First time around, you'll need to run migrations:

    bundle exec rake db:migrate

To run the web server:

    cd spec/dummy
    bundle exec rails s

Then navigate to http://localhost:3000/metrics.

## Config options

By default, the engine expects to find a config file called `jira-team-metrics.yml` in the app's `config` directory.

To specify a different location, specify a `CONFIG_DIR` environment variable:

    CONFIG_DIR=/path/to/config_dir bundle exec rails s

To start the server in read-only mode, set a `READONLY` environment variable:

    READONLY=1 bundle exec rails s

(Note that in this mode you can still resync data, but you can't edit board or domain configs.)

## Mount as an engine

If you want to customize how you deploy the app, you can create your own Rails app and add it as a dependency to your Gemfile:

    gem 'jira_team_metrics', :git => 'https://github.com/jbrunton/jira-team-metrics.git'
    
Then mount it as a Rails engine in your routes.rb file:

    Rails.application.routes.draw do
      mount JiraTeamMetrics::Engine => '/metrics'
    end
