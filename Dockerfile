#FROM debian:bullseye-slim
FROM ruby:3.0
USER root

RUN apt-get update 

# Create the application user/group and application directory
RUN groupadd -g 40054 alma && \
    useradd -r -s /sbin/nologin -M -u 40054 -g alma alma && \
    mkdir -p /opt/app && \
    chown -R alma:alma /opt/app 

# Run everything else as the alma user
WORKDIR /opt/app

COPY --chown=alma Gemfile* ./
RUN bundle install --system
COPY --chown=alma . .

USER alma
ENTRYPOINT ["/opt/app/bin/gobi"]
CMD ["help"]
