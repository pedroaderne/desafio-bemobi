FROM ruby:3.4.4

ENV BUNDLE_FORCE_RUBY_PLATFORM=true

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  pkg-config \
  libpq-dev \
  nodejs \
  postgresql-client

WORKDIR /app

COPY Gemfile ./

RUN gem install bundler && \
    bundle config set --global force_ruby_platform true && \
    bundle install

COPY . .

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]