# jira-team-metrics

[![Build Status](https://travis-ci.org/jbrunton/jira-team-metrics.svg?branch=master)](https://travis-ci.org/jbrunton/jira-team-metrics)
[![Code Climate](https://codeclimate.com/github/jbrunton/jira-team-metrics/badges/gpa.svg)](https://codeclimate.com/github/jbrunton/jira-team-metrics)

A command line tool for generating flow metrics from JIRA.

## Getting Started

Clone and install dependencies:

    git clone https://github.com/jbrunton/jira-team-metrics.git
    cd jira-team-metrics
    bundle install

Run the quickstart command to add and sync a domain:

    thor config:quickstart
    
Run the web server for pretty charts and reports:

    rakeup config.ru

Note that all configuration and data syncing happens through the command line. You can get further help on commands using thor:

    thor help -- help using thor
    thor list -- list available commands
    thor help <command> -- help for a specific command
    
