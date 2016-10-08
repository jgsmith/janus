FROM alpine

ENV APK_PACKAGES \
        erlang-asn1 \
        erlang-crypto \
        erlang-dev \
        erlang-erl-interface \
        erlang-eunit \
        erlang-inets \
        erlang-parsetools \
        erlang-public-key \
        erlang-sasl \
        erlang-ssl \
        erlang-syntax-tools

RUN apk --update add $APK_PACKAGES \
    && rm -rf /var/cache/apk/*

ENV ELIXIR_VERSION 1.3.1

RUN apk --update add --virtual build-dependencies wget ca-certificates && \
    wget --no-check-certificate https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/Precompiled.zip && \
    mkdir -p /opt/elixir-${ELIXIR_VERSION}/ && \
    unzip Precompiled.zip -d /opt/elixir-${ELIXIR_VERSION}/ && \
    rm Precompiled.zip && \
    apk del build-dependencies && \
    rm -rf /etc/ssl && \
    rm -rf /var/cache/apk/*

ENV PATH $PATH:/opt/elixir-${ELIXIR_VERSION}/bin

RUN mkdir -p /app/

COPY . /app/

WORKDIR /app/

RUN mix local.hex --force \
    && mix local.rebar --force \
    && rm -rf /var/cache/apk/*

RUN mix deps.get --force \
    && mix

CMD ["/bin/sh"]
