FROM ruby:2.6.5-buster AS development

WORKDIR /usr/src

ENV HOME=/usr/src PATH=/usr/src/bin:$PATH

COPY Gemfile Gemfile.lock on_container.gemspec /usr/src/
COPY lib/on_container/version.rb /usr/src/lib/on_container/

RUN bundle install --jobs=4 --retry=3

ARG DEVELOPER_UID=1000

ARG DEVELOPER_USERNAME=you

ENV DEVELOPER_UID=${DEVELOPER_UID}

RUN useradd -r -M -u ${DEVELOPER_UID} -d /usr/src -c "Developer User,,," ${DEVELOPER_USERNAME}

FROM development AS testing

COPY . /usr/src/
