FROM ruby:2.4-alpine

ENV RAILS_LOG_TO_STDOUT=1

RUN apk update && \
    apk upgrade && \
    apk add --update curl-dev ruby-dev build-base bash zlib-dev libxml2-dev libxslt-dev tzdata postgresql-dev postgresql-client ruby-json yaml nodejs openjdk8-jre-base && \
    rm -rf /var/cache/apk/* && \
    echo "user:x:1000:1000:user:/:/sbin/nologin" >> /etc/passwd && \
    mkdir -p /app

WORKDIR /app

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN bundle config build.nokogiri --use-system-libraries && \
            bundle install --jobs=3 --retry=3 && \
            bundle clean

COPY . /app

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
