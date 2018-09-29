FROM node:8.11.4-alpine

LABEL maintainer "inotom"
LABEL title="middleman-dev"
LABEL version="4"
LABEL description="Middleman/Node.js development environment with Docker"

ENV HOME=/home/app
ENV RUBYOPT=-EUTF-8
ENV PATH=$HOME/.npm-global/bin:$PATH
ENV PATH=./node_modules/.bin:$PATH

# shadow packages (https://pkgs.alpinelinux.org/contents?file=&path=&name=shadow&branch=v3.5&repo=community&arch=x86_64)
RUN \
  apk update \
  && apk add --no-cache sudo shadow zip tzdata git build-base ruby ruby-dev ruby-json \
  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
  && apk del tzdata \
  && gem install -N bundler \
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
