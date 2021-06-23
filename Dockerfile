FROM python:3.8-buster

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Install pip requirements
COPY . .
RUN python -m pip install -r requirements.txt

# Download and install required tools.
RUN curl -L https://get.pulumi.com/ | bash
ENV PATH=$PATH:/root/.pulumi/bin

ENTRYPOINT [ "pulumi", "version" ]
