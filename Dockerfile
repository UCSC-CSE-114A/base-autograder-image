# We use the official edulinq python grader for Ubuntu.
# https://github.com/edulinq/autograder-docker-python/blob/0.1.0.1/ubuntu/Dockerfile
FROM ghcr.io/edulinq/grader.python:0.1.0.1-ubuntu22.04

ARG GHC_VERSION=9.4.7
ARG STACK_RESOLVER=lts-21.14

ENV HOME="/root"

RUN apt-get update

RUN apt-get install -y \
    build-essential \
    curl \
    libffi-dev \
    libffi8ubuntu1 \
    libgmp-dev \
    libgmp10 \
    libncurses-dev \
    libncurses5 \
    libtinfo5

WORKDIR /autograder/work

# Add custom stack.yaml for shared dependencies.
COPY stack.yaml /autograder/work/stack.yaml
COPY dummy-package /autograder/work/dummy-package/

RUN mkdir -p ~/.ghcup/bin

RUN curl -o ~/ghcup https://downloads.haskell.org/~ghcup/$(uname -m)-linux-ghcup
RUN chmod +x ~/ghcup
RUN mv ~/ghcup ~/.ghcup/bin/

# TODO: One-line for paths and ENVs
RUN echo "PATH=\$HOME/.local/bin:\$PATH" >> .bashrc
RUN echo "PATH=\$HOME/.ghcup/bin:\$PATH" >> .bashrc
RUN echo "PATH=\$HOME/.cabal/store/bin:\$PATH" >> .bashrc

ENV PATH="$HOME/.local/bin:$HOME/.ghcup/bin:$PATH"
ENV PATH="$HOME/.cabal/store/bin:$PATH"

RUN ghcup install ghc "${GHC_VERSION}" --set \
    && ghcup install cabal recommended --set \
    && ghcup install stack recommended --set \
    && cabal update

ENV STACK_ROOT=/root/.stack

# Install GHC for the stack.yaml resolver.
RUN stack config set system-ghc --global true
RUN stack build --resolver=${STACK_RESOLVER} --only-dependencies


RUN stack build
