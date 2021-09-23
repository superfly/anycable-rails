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
    postgresql-client file rsync git build-essential libpq-dev wget vim curl gzip xz-utils \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives


RUN curl -sO https://nodejs.org/dist/v16.0.0/node-v16.0.0-linux-x64.tar.xz && cd /usr/local && tar --strip-components 1 -xvf /app/node*xz && rm /app/node*xz && cd ~

RUN gem install -N bundler -v 2.2.27
RUN npm install -g yarn

ENV PATH $PATH:/usr/local/bin

COPY bin/rsync-cache bin/rsync-cache

# Install rubygems
COPY Gemfile* ./

ENV BUNDLE_WITHOUT development:test

RUN bundle install

COPY package.json yarn.lock ./

RUN --mount=type=cache,target=/cache,id=node \
    bin/rsync-cache /cache node_modules "yarn"

COPY Rakefile Rakefile
COPY bin bin
COPY vendor vendor
COPY config config
COPY lib lib
COPY public public
COPY babel.config.js babel.config.js
COPY postcss.config.js postcss.config.js
COPY app/assets app/assets
COPY app/javascript app/javascript

ENV NODE_ENV production
ENV SECRET_KEY_BASE=1

RUN --mount=type=cache,id=cache,sharing=locked,target=/cache \
    ASSET_COMPILATION=1 bin/rsync-cache /cache "tmp/cache public/packs public/assets" "bundle exec rake assets:precompile" && \
    rm -rf node_modules tmp/cache

RUN rm -rf vendor/bundle/ruby/*/cache

COPY . .

FROM quay.io/evl.ms/fullstaq-ruby:${RUBY_VERSION}-slim

ARG RAILS_ENV=production

RUN --mount=type=cache,id=apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    postgresql-client file git wget vim curl gzip curl \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV=${RAILS_ENV}
ENV RAILS_SERVE_STATIC_FILES true
ENV BUNDLE_PATH vendor/bundle
ENV BUNDLE_WITHOUT development:test
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

RUN curl -L https://github.com/anycable/anycable-go/releases/download/v1.1.3/anycable-go-linux-amd64 -o /bin/anycable-go && chmod 755 /bin/anycable-go

COPY --from=build /app /app

WORKDIR /app

RUN mkdir -p tmp/pids
EXPOSE 8080

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
