FROM ruby:3.2
ARG UNAME=app
ARG UID=1000
ARG GID=1000

LABEL maintainer="mrio@umich.edu"

RUN gem install bundler

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir -p /gems && chown ${UID}:${GID} /gems


COPY --chown=${UID}:${GID} Gemfile* /app/
USER $UNAME

ENV BUNDLE_PATH /gems

#Actually a secret
ENV ALMA_WEBHOOK_SECRET=secret

WORKDIR /app
RUN bundle install

COPY --chown=${UID}:${GID} . /app

CMD ["bundle", "exec", "sidekiq", "-r", "./worker.rb"]
