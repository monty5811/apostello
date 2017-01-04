FROM ubuntu:14.04
RUN apt-get update && \
        apt-get install -y \
        python-pip \
        python-dev \
        openssh-server \
        libssl-dev \
        libffi-dev \
        curl \
        && apt-get clean \
        && rm -rf /var/cache/apt/* /var/lib/apt/lists/*
RUN pip install \
    paramiko \
    PyYAML \
    Jinja2 \
    httplib2 \
    six
RUN pip install ansible==2.2.0.0
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
RUN mkdir /code
WORKDIR /code
ADD . /code/
