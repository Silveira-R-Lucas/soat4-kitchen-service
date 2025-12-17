FROM ruby:3.2
RUN apt-get update -qq && apt-get install -y nodejs build-essential
WORKDIR /app
COPY Gemfile* ./
RUN bundle install
COPY . .
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
