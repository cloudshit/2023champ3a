FROM alpine

RUN apk add --no-cache libc6-compat 
RUN adduser --disabled-password app

RUN mkdir /app
WORKDIR /app

COPY ./token-arm64 /app/app
RUN chmod a+rx /app/app

USER app

CMD ["./app"]
