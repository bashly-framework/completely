FROM dannyben/alpine-ruby:3.3.3

ENV PS1="\n\n>> completely \W \$ "
WORKDIR /app

RUN gem install completely --version 0.7.3

ENTRYPOINT ["completely"]