FROM alpine:3.11.3

RUN apk update && apk add stress-ng bash

ENV timeout=5m

RUN mkdir -p /usr/app
COPY ./stress.sh /usr/app/stress.sh


CMD ["bash", "/usr/app/stress.sh"]
