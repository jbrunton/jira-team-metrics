# jira-team-metrics

[![Build Status](https://travis-ci.org/jbrunton/jira-team-metrics.svg?branch=master)](https://travis-ci.org/jbrunton/jira-team-metrics)
[![Code Climate](https://codeclimate.com/github/jbrunton/jira-team-metrics/badges/gpa.svg)](https://codeclimate.com/github/jbrunton/jira-team-metrics)

A command line tool for generating flow metrics from JIRA.

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
