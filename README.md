# jira-team-metrics

[![Build Status](https://travis-ci.org/jbrunton/jira-team-metrics.svg?branch=master)](https://travis-ci.org/jbrunton/jira-team-metrics)
[![Code Climate](https://codeclimate.com/github/jbrunton/jira-team-metrics/badges/gpa.svg)](https://codeclimate.com/github/jbrunton/jira-team-metrics)

A reporting tool for visualising flow metrics for JIRA projects.

## Getting Started

Clone and install dependencies:

    git clone https://github.com/jbrunton/jira-team-metrics.git
    cd jira-team-metrics
    bundle install

First time around, you'll need to run migrations:

    bundle exec rake db:migrate

To use, run the web server:

    bundle exec rails s

Then navigate to http://localhost:3000/ and add a domain to analyze.

## Server options

To use a remote config file, set a `CONFIG_URL` environment variable pointing to the file:

    CONFIG_URL=https://my.config.yml bundle exec rails s

To start the server in read-only mode, set a `READONLY` environment variable:

    READONLY=1 bundle exec rails s

(Note that in this mode you can still resync data, but you can't edit board or domain configs.)
