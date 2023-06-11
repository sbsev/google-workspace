FROM ubuntu:latest as INSTALLER
COPY . .
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install python3 python3-pip git -y \
    && apt-get install swig libpcsclite-dev -y \
    && pip install -r requirements.txt \
    && pip install -U git+https://github.com/jay0lee/GAM.git#subdirectory=src

CMD "bash <(curl -s -S -L https://gam-shortn.appspot.com/gam-install)"