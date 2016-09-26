FROM		ruby:2.3.1-alpine
MAINTAINER	Marcelo Pinheiro <salizzar@gmail.com>

WORKDIR		/opt/tdc-nosql-redis

COPY		Gemfile* /opt/tdc-nosql-redis/

RUN		apk add --update openssl-dev make g++	;	\
		ruby -S gem install bundler		&&	\
		ruby -S bundle install 			;	\
		apk del make g++

