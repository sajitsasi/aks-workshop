FROM alpine:3.11.3

RUN apk update && apk add stress-ng

ENV nworkers=0

ENV cpuload=4

ENV timeout=60

CMD stress-ng --cpu ${nworkers} --cpu-method all --cpu-load ${cpuload} --timeout ${timeout}
