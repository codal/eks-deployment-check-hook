FROM python:3.10.0a7-alpine3.13

LABEL maintainer="Yash Pandya <ypandya@codal.com>"

ENV PYTHONIOENCODING=UTF-8

RUN apk add --no-cache curl

RUN apk add --no-cache bash

RUN pip install awscli
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["bash", "entrypoint.sh"]
