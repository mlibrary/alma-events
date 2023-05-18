ARG RUBY_VERSION=3.1
FROM ruby:${RUBY_VERSION}

ARG UNAME=app
ARG UID=1000
ARG GID=1000


#RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  #vim-tiny 
  #ssh

RUN gem install bundler

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir -p /gems && chown ${UID}:${GID} /gems


USER $UNAME

ENV BUNDLE_PATH /gems

WORKDIR /app

CMD ["bundle", "exec", "ruby", "alma_webhook.rb", "-o", "0.0.0.0"]
