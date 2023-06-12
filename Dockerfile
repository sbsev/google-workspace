FROM ubuntu:latest as INSTALLER
COPY . .
RUN apt-get update 
RUN apt-get -y upgrade 
RUN apt-get install curl -y 
# RUN apt-get install python3 python3-pip -y

RUN apt-get install swig libpcsclite-dev xz-utils -y 
# RUN pip install -r requirements.txt 
RUN chmod +x install.sh

CMD ["bash", "-c", "--", "while true; do sleep 30; done;"]