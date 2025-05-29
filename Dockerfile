FROM ruby:3.2

WORKDIR /app

# Install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Add app files
COPY . .
RUN chmod +x start.sh
# Run Puma with our custom config
CMD ["bash", "start.sh"]
