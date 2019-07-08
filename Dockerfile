FROM centos/ruby-25-centos7:latest
MAINTAINER Eguzki Astiz Lezaun <eastizle@redhat.com>

USER root
WORKDIR /opt/app-root/src
COPY . .
RUN /bin/bash -l -c "gem build 3scale_toolbox.gemspec"
RUN /bin/bash -l -c "gem install 3scale_toolbox-*.gem --no-document"

# clean up
RUN rm -rf /opt/app-root/src/*

# Drop privileges
USER default
