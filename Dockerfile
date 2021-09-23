# syntax = docker/dockerfile:experimental

ARG RUBY_VERSION=3.0.0-jemalloc
FROM quay.io/evl.ms/fullstaq-ruby:${RUBY_VERSION}-slim as build

ARG RAILS_ENV=production
ARG RAILS_MASTER_KEY
ENV RAILS_ENV=${RAILS_ENV}
ENV BUNDLE_PATH vendor/bundle
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

RUN mkdir /app
WORKDIR /app

# Reinstall runtime dependencies that need to be installed as packages

RUN --mount=type=cache,id=apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    file git build-essential libpq-dev vim curl gzip \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN gem install -N bundler -v 2.2.27

ENV PATH $PATH:/usr/local/bin

COPY Gemfile* ./
ENV BUNDLE_WITHOUT development:test
RUN bundle install

COPY . .

FROM quay.io/evl.ms/fullstaq-ruby:${RUBY_VERSION}-slim

ARG RAILS_ENV=production

RUN --mount=type=cache,id=apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    postgresql-client file git vim curl gzip \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN curl -L https://github.com/anycable/anycable-go/releases/download/v1.1.3/anycable-go-linux-amd64 -o /bin/anycable-go && chmod 755 /bin/anycable-go

ENV RAILS_ENV=${RAILS_ENV}
ENV RAILS_SERVE_STATIC_FILES true
ENV BUNDLE_PATH vendor/bundle
ENV BUNDLE_WITHOUT development:test
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

COPY --from=build /app /app

WORKDIR /app

RUN mkdir -p tmp/pids
EXPOSE 8080

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
