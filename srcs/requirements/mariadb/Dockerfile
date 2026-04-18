FROM debian:bookworm

RUN apt update && \
	apt upgrade && \
	apt-get install -y mariadb-server mariadb-client && \
	rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/conf.d/

COPY tools/run.sh /usr/local/bin/

CMD["chmod", "+x", "/usr/local/bin/run.sh"]

ENTRYPOINT["/usr/local/bin/run.sh"]

EXPOSE 3306
