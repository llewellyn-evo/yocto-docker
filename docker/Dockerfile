FROM debian:stretch
MAINTAINER Maksym Maksym <komar@evologics.de>

ENV DEBIAN_FRONTEND noninteractive

RUN printf 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";\n' > \
    /etc/apt/apt.conf.d/000main

RUN apt-get update -y && apt-get install -y locales
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN echo en_US.UTF-8 UTF-8 >> /etc/locale.gen && locale-gen && \
    \
    apt-get update -y && apt-get install -y locales && \
    apt-get install -y file gawk wget git-core diffstat unzip texinfo gcc-multilib \
        build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
        xz-utils debianutils iputils-ping libncurses5-dev libtinfo-dev \
        build-essential sudo wget git-core perl-base \
        libncurses5-dev libtinfo-dev \
        tmux screen bash-completion vim-tiny \
        openssh-client rsync \
    && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /work

# Add entry point, we use entrypoint.sh to mapping host user to container
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
