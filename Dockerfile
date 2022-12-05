FROM elixir:1.14.2-alpine

ENV MIX_ENV=prod

WORKDIR /app
COPY . /app

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix do compile

EXPOSE 4040

CMD mix run --no-halt
