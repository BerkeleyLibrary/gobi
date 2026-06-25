#FROM debian:bullseye-slim
FROM ruby:3.3-slim AS base
USER root

RUN apt-get update 

# Create the application user/group and application directory
RUN groupadd -g 40054 alma && \
    useradd -r -s /sbin/nologin -M -u 40054 -g alma alma && \
    mkdir -p /opt/app && \
    chown -R alma:alma /opt/app 

WORKDIR /opt/app

FROM base AS development

USER root

# Install system packages needed to build gems with C extensions.
RUN apt-get install -y --no-install-recommends \
    g++ \
    git \
    make

USER alma

RUN gem install bundler --version 4.0.9
COPY --chown=alma:alma Gemfile* ./
RUN bundle install
COPY --chown=alma:alma . .

FROM base AS production

# Copy the built codebase from the dev stage
COPY --from=development --chown=alma /opt/app /opt/app
COPY --from=development --chown=alma /usr/local/bundle /usr/local/bundle

# Ensure the bundle is installed and the Gemfile.lock is synced.
RUN bundle config set frozen 'true'
RUN bundle install --local
USER alma
ENTRYPOINT ["/opt/app/bin/gobi"]
#CMD ["help"]
