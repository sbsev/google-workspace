FROM ubuntu:latest

COPY . /home/
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install curl swig libpcsclite-dev xz-utils -y && \
    chmod +x /home/install.sh

CMD ["bash", "-c", "--", "while true; do sleep 30; done;"]
