FROM ubuntu:18.04

MAINTAINER Patrick Pedrioli
LABEL Description="A base container for user matching between host-image" Version="1.0"

## Let apt-get know we are running in noninteractive mode
ENV DEBIAN_FRONTEND noninteractive

## Setup GOSU to match user and group ids
##
## User: user
## Pass: 123
## 
## Note that this setup also relies on entrypoint.sh
## Set LOCAL_USER_ID as an ENV variable at launch or the default uid 1000 will be used
## Set LOCAL_GROUP_ID as an ENV variable at launch or the default uid 1000 will be used
## (e.g. docker run -e LOCAL_USER_ID=151149 ....)
##
## Initial password for user will be 123
ENV GOSU_VERSION 1.9
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates wget gnupg \
    && mkdir ~/.gnupg \
    && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
    && rm -rf /var/lib/apt/lists/* \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

# Create user user
ENV USER_ID 1000
ENV GROUP_ID 1000
ENV HOME /home/user
RUN addgroup --gid $GROUP_ID userg \
    && useradd --shell /bin/bash -u $USER_ID -g $GROUP_ID -o -c "" -m user \
    && chown -R user:userg $HOME \
    && echo 'user:123' | chpasswd

## Make sure the user inside the docker has the same ID as the user outside
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

