FROM python:3.8-alpine

RUN apk update && apk add tzdata curl && \
    cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Berlin" > /etc/timezone && \
    apk del tzdata && rm -rf /var/cache/apk/*

RUN pip3 install odoorpc

CMD chown root:root /etc/crontabs/root && /usr/sbin/crond -f
