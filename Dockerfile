FROM python:3.7-alpine
WORKDIR /code
RUN apk add --no-cache --virtual \
        libffi \
        libssl1.1 \
        openssl \
        ca-certificates \
        binutils
RUN apk add --no-cache --virtual .build-deps \
        gcc \
        linux-headers \
        openssl-dev \
        musl-dev \
        libffi-dev

COPY requirements.txt .

RUN pip install -r ./requirements.txt

COPY ./certbot_hook.py .
COPY ./config.py .

ENTRYPOINT ["certbot", "certonly", "-n", "--agree-tos", "--manual-public-ip-logging-ok", "--preferred-challenges", "dns", "--manual", "--manual-auth-hook", "python /code/certbot_hook.py", "--manual-cleanup-hook", "python /code/certbot_hook.py"]
