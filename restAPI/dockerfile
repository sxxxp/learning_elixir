FROM elixir:latest

MAINTAINER sxxxp "junhyeonsin@gmail.com"


COPY . .
WORKDIR /restapi
RUN apt-get update
RUN ls -al /restapi
RUN mix local.hex --force && mix local.rebar --force
RUN mix hex.info  
RUN rm -f mix.lock 
RUN mix deps.get  

RUN echo "This is an Elixir server container"

CMD ["mix", "run", "--no-halt"]

EXPOSE 4000
