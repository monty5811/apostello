FROM python:3.4
ENV PYTHONUNBUFFERED 1
RUN pip install -U pip
RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/
RUN pip install -r requirements.txt --upgrade
ADD . /code/
