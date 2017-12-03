FROM ruby:2.3.3
MAINTAINER Bryan Alves <bryanalves@gmail.com>

RUN mkdir /app
WORKDIR /app
COPY Gemfile* /app/
RUN bundle install

COPY . /app

# Start server
EXPOSE 9100
CMD ["bundle", "exec", "ruby", "app.rb"]
