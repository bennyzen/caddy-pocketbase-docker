FROM caddy:2.10-builder AS builder

RUN xcaddy build \
    --with github.com/mohammed90/caddy-pocketbase@latest

FROM caddy:2.10

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
