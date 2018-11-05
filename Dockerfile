FROM node:10.13.0-alpine as node
FROM ruby:2.5.3-alpine3.8

LABEL maintainer "inotom"
LABEL title="middleman-dev"
LABEL version="5"
LABEL description="Middleman/Node.js development environment with Docker"

ENV HOME=/home/app
ENV RUBYOPT=-EUTF-8
ENV PATH=$HOME/.npm-global/bin:$PATH
ENV PATH=./node_modules/.bin:$PATH
ENV YARN_VERSION 1.10.1

RUN mkdir /opt
COPY --from=node /opt/yarn-v$YARN_VERSION /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN \
  ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg \
  && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx


# shadow packages (https://pkgs.alpinelinux.org/contents?file=&path=&name=shadow&branch=v3.5&repo=community&arch=x86_64)
RUN \
  apk update \
  && apk add --no-cache sudo shadow zip tzdata git build-base ruby-dev ruby-json ruby-bundler \
  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
  && apk del tzdata \
  && useradd --user-group --create-home --shell /bin/false app \
  && echo "app ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR $HOME/work

COPY Gemfile Gemfile.lock .gemrc package.json package-lock.json .npmrc $HOME/work/
RUN \
  chown -R app:app $HOME/*

USER app
WORKDIR $HOME/work
RUN \
  mkdir $HOME/.npm-global \
  && npm config set prefix $HOME/.npm-global \
  && npm install -g npm@6.4.1 \
  && npm cache verify \
  && mkdir node_modules \
  && bundle install

EXPOSE 4567
