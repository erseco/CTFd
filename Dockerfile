FROM alpine:3.11

WORKDIR /opt/CTFd
RUN mkdir -p /opt/CTFd /var/log/CTFd /var/uploads

COPY requirements.txt .

# Install build deps, then run `pip install`, then remove unneeded build deps all in a single step. Correct the path to your production requirements fil
RUN apk add --no-cache \
        python3 \
        py3-yaml \
        py3-requests \
        py3-bcrypt \
        py3-cffi \
        py3-hiredis \
        py3-gevent \
        py3-pyrsistent \
        py3-greenlet \
        py3-markupsafe \
        py3-attrs \
        py3-dateutil \
        py3-boto \
        py3-sqlalchemy \
        py3-psycopg2 \
        py3-text-unidecode \
        py3-jsonschema \
        py3-tz \
        py3-jinja2 \
        py3-click \
        py3-pathlib2 \
        py3-redis \
        py3-gunicorn \
        py3-netaddr \
        py3-greenlet \
    && \
        apk add --no-cache --virtual .build-deps  \
            build-base \
            python3-dev \
            libffi-dev \
            openssl-dev \
    && \
        pip3 install -r requirements.txt \
    && \
        apk del .build-deps --force-broken-world \
    && \
        find /usr/local -depth \
            \( \
                \( -type d -a \( -name test -o -name tests \) \) \
                -o \
                \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
            \) -exec rm -rf '{}' + \
        && rm -rf /usr/src/python \
        && rm -rf /root/.cache

COPY . /opt/CTFd

RUN chmod +x /opt/CTFd/docker-entrypoint.sh
RUN adduser -D -u 1001 -s /bin/sh ctfd
RUN chown -R 1001:1001 /opt/CTFd /var/log/CTFd /var/uploads

USER 1001
EXPOSE 8000
CMD ["/opt/CTFd/docker-entrypoint.sh"]

