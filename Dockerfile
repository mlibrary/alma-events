################################################################################
# DEVELOPMENT
################################################################################
FROM ruby:4.0-slim-trixie@sha256:86a2ff44ce474c1c9bd11dfb2fd7fe5408a5bfe8236b9bc6013e2c6ef4c02d39 AS development

ARG UID=1000
ARG GID=1000

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  build-essential \
  libtool \ 
  libyaml-dev \
  git \
  curl \
  openssh-client \
  vim 

RUN groupadd -g ${GID} -o app
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash app

ENV GEM_HOME=/gems
ENV PATH="$PATH:/gems/bin"
RUN mkdir -p /gems && chown ${UID}:${GID} /gems

ENV BUNDLE_PATH=/app/vendor/bundle

USER app
RUN gem install bundler

WORKDIR /app

CMD ["bundle", "exec", "ruby", "alma_webhook.rb", "-o", "0.0.0.0"]

################################################################################
# PRODUCTION
################################################################################
FROM development AS production

ENV BUNDLE_WITHOUT=development:test

COPY --chown=${UID}:${GID} . /app

RUN bundle install
