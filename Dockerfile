FROM ubuntu:latest
RUN echo Updating existing packages, installing and upgrading python and pip.
RUN apt-get update -y
RUN apt-get install -y python3.6 python3-pip build-essential
RUN echo which pip3
RUN echo which python3
RUN echo Copying application files...
COPY ./app /app
WORKDIR /app
RUN echo Installing Python packages listed in requirements.txt
RUN pip3 install -r ./requirements.txt
RUN echo Starting python and starting the Flask service...
ENTRYPOINT ["python3"]
CMD ["app.py"]
