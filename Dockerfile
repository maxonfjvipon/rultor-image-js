# SPDX-FileCopyrightText: Copyright (c) 2024-2026 Max Trunnikov
# SPDX-License-Identifier: MIT

# The software packages configured here (Node and Ruby) are for
# the convenience of the users going to use this container for NodeJS
# projects.
# Rultor has no dependency on these packages.

FROM ubuntu:22.04
LABEL description="This is the default image for Rultor.com" version="0.0.2"
WORKDIR /tmp

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# To disable IPv6
RUN mkdir ~/.gnupg \
  && printf "disable-ipv6" >> ~/.gnupg/dirmngr.conf

# UTF-8 locale
RUN apt-get clean \
  && apt-get update -y --fix-missing \
  && apt-get -y --no-install-recommends install locales \
  && locale-gen en_US.UTF-8 \
  && dpkg-reconfigure locales \
  && printf "LC_ALL=en_US.UTF-8\nLANG=en_US.UTF-8\nLANGUAGE=en_US.UTF-8\n" > /etc/default/locale \
  && echo 'export LC_ALL=en_US.UTF-8' >> /root/.profile \
  && echo 'export LANG=en_US.UTF-8' >> /root/.profile \
  && echo 'export LANGUAGE=en_US.UTF-8' >> /root/.profile \
  && rm -rf /var/lib/apt/lists/*

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Basic Linux tools
RUN apt-get update -y \
  && apt-get -y --no-install-recommends install curl \
  software-properties-common \
  && rm -rf /var/lib/apt/lists/*

# Docker cli
RUN mkdir -p /tmp/download \
  && curl -s -L "https://download.docker.com/linux/static/stable/x86_64/docker-18.06.3-ce.tgz" | tar -xz -C /tmp/download \
  && mv /tmp/download/docker/docker /usr/bin/ \
  && rm -rf /tmp/download

# Git 2.0
RUN add-apt-repository ppa:git-core/ppa \
  && apt-get update -y --fix-missing \
  && apt-get -y --no-install-recommends install git \
  && bash -c 'git --version' \
  && rm -rf /var/lib/apt/lists/*

# SSH Daemon
RUN apt-get update -y \
  && apt-get -y --no-install-recommends install ssh \
  && mkdir /var/run/sshd \
  && chmod 0755 /var/run/sshd \
  && rm -rf /var/lib/apt/lists/*

# Ruby
RUN apt-get update -y \
  && apt-get -y --no-install-recommends install ruby-dev libmagic-dev zlib1g-dev openssl \
  && rm -rf /var/lib/apt/lists/* \
  && gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
  && curl -L https://get.rvm.io | bash -s stable \
  && echo "source /usr/local/rvm/scripts/rvm && rvm use 3.2.2 && rvm default 3.2.2" >> /root/.profile \
  && bash -l -c ". /etc/profile.d/rvm.sh && rvm pkg install openssl" \
  && bash -l -c ". /etc/profile.d/rvm.sh && rvm install ruby-3.2.2 --with-openssl-lib=/usr/lib --with-openssl-include=/usr/include" \
  && echo 'gem: --no-document' >> ~/.gemrc \
  && echo 'rvm_silence_path_mismatch_check_flag=1' >> ~/.rvmrc \
  && bash -l -c ". /etc/profile.d/rvm.sh \
  && rvm use 3.2.2 \
  && gem install bundler -v 2.3.26 \
  && gem install xcop -v 0.7.1 \
  && gem install pdd -v 0.23.1 \
  && gem install openssl -v 3.1.0"

# NodeJS 22
RUN rm -rf /usr/lib/node_modules \
  && curl -sL https://deb.nodesource.com/setup_22.x -o /tmp/nodesource_setup.sh \
  && bash /tmp/nodesource_setup.sh \
  && apt-get -y --no-install-recommends install nodejs \
  && bash -c 'node --version' \
  && bash -c 'npm --version' \
  && rm -rf /var/lib/apt/lists/*

# Clean up
RUN rm -rf /tmp/* \
  /root/.ssh \
  /root/.cache \
  /root/.gnupg

ENTRYPOINT ["/bin/bash", "--login", "-c"]
