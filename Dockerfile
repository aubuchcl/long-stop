FROM ruby:3.2

WORKDIR /app

COPY Gemfile ./
RUN bundle install --full-index

COPY . .

RUN mkdir -p tmp/pids

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec puma -C config/puma.rb -b tcp://[::]:3000"]
