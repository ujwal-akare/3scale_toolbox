FROM ruby:2.7
MAINTAINER Eguzki Astiz Lezaun <eastizle@redhat.com>

WORKDIR /usr/src/app
COPY . .
RUN gem build 3scale_toolbox.gemspec
RUN gem install 3scale_toolbox-*.gem --no-document
RUN adduser  --home /home/toolboxuser toolboxuser
WORKDIR /home/toolboxuser

# clean up
RUN rm -rf /usr/src/app

# Drop privileges
USER toolboxuser
