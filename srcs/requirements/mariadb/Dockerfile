FROM debian:bookworm

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y mariadb-server mariadb-client gettext-base && \
    rm -rf /var/lib/apt/lists/*

COPY tools/run.sh /usr/local/bin/
COPY conf/init.sql /

RUN chmod +x /usr/local/bin/run.sh

ENTRYPOINT ["/usr/local/bin/run.sh"]

EXPOSE 3306
