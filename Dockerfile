FROM debian:stable-slim

# how to execute
# alias zcli="docker run --rm -it -v $HOME/.zcli:/root/.zcli zcli:debian zcli"

SHELL ["/bin/bash", "-c"]

WORKDIR /zcli

COPY . .
RUN mkdir -p /root/.cpan/CPAN && mv docker_cpan.conf /root/.cpan/CPAN/MyConfig.pm

# install
RUN apt-get update
RUN ./install.sh -docker

# clean env
RUN rm -rf /root/.cpan
RUN apt-get remove -y gcc make
RUN apt-get autoremove -y
RUN apt-get clean -y

CMD [ "/bin/bash", "-c", "zcli" ]
