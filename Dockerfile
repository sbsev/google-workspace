FROM ubuntu:latest

COPY . /home/
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install curl swig libpcsclite-dev xz-utils python3 -y && \
    bash -c "bash <(curl -s -S -L https://gam-shortn.appspot.com/gam-install) -l" && \
    echo "alias gam=/root/bin/gam7/gam" > /root/.bash_aliases

ENV PATH="${PATH}:/root/bin/gam7/gam"

# You need to download these files from the internal git repository
# and place them in the same directory as the Dockerfile
COPY oauth2service.json /root/.gam/oauth2service.json
COPY client_secrets.json /root/.gam/client_secrets.json

CMD ["bash", "-c", "sleep infinity"]
