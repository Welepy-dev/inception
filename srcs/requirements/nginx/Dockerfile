FROM debian:bookworm

RUN apt update && \
	apt upgrade && \
	apt-get install -y nginx openssl && \
	rm -rf /var/lib/apt/lists/*
