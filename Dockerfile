# Using the official Haskell slim docker image.
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update

RUN apt-get install -y \
    locales \
    tzdata

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN locale-gen

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

RUN apt-get clean

RUN useradd --create-home --shell /bin/bash grader

WORKDIR /home/grader

# Add custom stack.yaml for shared dependencies.
COPY stack.yaml /home/grader/
COPY dummy-package /home/grader/

RUN chown -R grader:grader /home/grader

USER grader

RUN ls -la /home/grader
RUN echo $HOME

ENV GHCUP_INSTALL_BASE_PREFIX=/home/grader
ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1
ENV PATH="/home/grader/.ghcup/bin:$PATH"

RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh -s -- -y && \
  echo "source /home/grader/.ghcup/env" >> /home/grader/.bashrc

# [Choice] GHC version: recommended, latest, 9.2, 9.0, 8.10, 8.8, 8.6
ARG GHC_VERSION=9.4.7
ARG STACK_RESOLVER=lts-21.13

RUN /home/grader/.ghcup/bin/ghcup install ghc "${GHC_VERSION}" && \
    /home/grader/.ghcup/bin/ghcup set ghc "${GHC_VERSION}" && \
    /home/grader/.ghcup/bin/ghcup install stack && \
    /home/grader/.ghcup/bin/ghcup set stack

# Install GHC for the stack.yaml resolver.
RUN stack config set system-ghc --global true
RUN stack install --resolver=${STACK_RESOLVER}
RUN stack build

CMD [ "echo", "CSE 114A Grading Base Image" ]
