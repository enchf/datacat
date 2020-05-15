FROM ruby:2.6.5-alpine3.9

RUN apk update && apk add build-base git bash

RUN mkdir /datacat
VOLUME /datacat
WORKDIR /datacat

COPY . .

RUN rm Gemfile.lock
RUN rm *.gem

RUN gem install bundler
RUN bundle install
RUN gem build datacat.gemspec -o datacat-latest.gem
RUN gem install datacat

LABEL maintainer="Ernesto Espinosa <e.ernesto.espinosa@gmail.com>"

CMD ruby /datacat/scripts/random_sorting.rb & datacat
