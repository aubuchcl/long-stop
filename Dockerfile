FROM ruby:3.2

WORKDIR /app

# Install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Add app files
COPY . .

# Run Puma with our custom config
CMD ["bash", "start.sh"]
