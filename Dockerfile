FROM ruby:2.6.5-buster AS development

WORKDIR /usr/src

ENV HOME=/usr/src PATH=/usr/src/bin:$PATH

COPY Gemfile Gemfile.lock omniauth-icalia.gemspec /usr/src/
COPY lib/omniauth-icalia/version.rb /usr/src/lib/omniauth-icalia/

RUN bundle install --jobs=4 --retry=3

ARG DEVELOPER_UID=1000

ARG DEVELOPER_USERNAME=you

ENV DEVELOPER_UID=${DEVELOPER_UID}

RUN useradd -r -M -u ${DEVELOPER_UID} -d /usr/src -c "Developer User,,," ${DEVELOPER_USERNAME}

FROM development AS testing

COPY . /usr/src/
