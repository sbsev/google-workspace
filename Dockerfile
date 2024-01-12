FROM ubuntu:latest

COPY . /home/
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install curl swig libpcsclite-dev xz-utils -y && \
    bash -c "bash <(curl -s -S -L https://gam-shortn.appspot.com/gam-install) -l" && \
    echo "alias gam=/root/bin/gam/gam" > /root/.bash_aliases

ENV PATH="${PATH}:/root/bin/gam/gam"

COPY oauth2service.json /root/bin/gam/oauth2service.json
COPY client_secrets.json /root/bin/gam/client_secrets.json
COPY roots.pem /root/bin/gam/roots.pem

CMD ["bash", "-c", "sleep infinity"]
