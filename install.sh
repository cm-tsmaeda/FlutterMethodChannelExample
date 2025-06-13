#!/bin/sh

## install Bundler

# gem install bundler --no-document --version  '= 2.3.7'

## install Gems

bundle config set --local path 'vendor/bundle'
bundle install

## install pods

# bundle exec pod install --repo-update

