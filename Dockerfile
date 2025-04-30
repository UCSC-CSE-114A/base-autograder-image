# We use the official edulinq python grader for Ubuntu.
# https://github.com/edulinq/autograder-docker-python/blob/0.1.0.1/ubuntu/Dockerfile
FROM ghcr.io/edulinq/grader.python:0.1.0.2-alpine3.20.3 AS build-stage

ARG GHC_VERSION=9.4.7
ARG STACK_RESOLVER=lts-21.14

ENV HOME="/root"

RUN apk update

RUN apk add --no-cache \
    build-base \
    curl \
    libffi-dev \
    libffi \
    gmp-dev \
    gmp \
    ncurses \
    ncurses-dev \
    zlib-dev

WORKDIR /autograder/work

# Add custom stack.yaml for shared dependencies.
COPY stack.yaml /autograder/work/stack.yaml
COPY dummy-package /autograder/work/dummy-package/

RUN mkdir -p ~/.ghcup/bin

RUN curl -o ~/ghcup https://downloads.haskell.org/~ghcup/$(uname -m)-linux-ghcup
RUN chmod +x ~/ghcup
RUN mv ~/ghcup ~/.ghcup/bin/

RUN echo "PATH=\$HOME/.local/bin:\$HOME/.ghcup/bin:\$HOME/.cabal/store/bin:\$PATH" >> $HOME/.bashrc
ENV PATH="$HOME/.local/bin:$HOME/.ghcup/bin:$HOME/.cabal/store/bin:$PATH"

RUN ghcup install ghc "${GHC_VERSION}" --set
RUN ghcup install cabal recommended --set
RUN ghcup install stack recommended --set
RUN cabal update

ENV STACK_ROOT=/root/.stack

# Install GHC for the stack.yaml resolver.
RUN stack config set system-ghc --global true
RUN stack build --resolver=${STACK_RESOLVER} --only-dependencies --jobs=1

RUN stack build --jobs=1

# Remove unnecessary build artifacts.
RUN mkdir -p /tmp/.ghcup/bin
RUN mkdir -p /tmp/.ghcup/ghc

RUN cp -r /root/.ghcup/bin/stack /tmp/.ghcup/bin/
RUN cp -r /root/.ghcup/ghc/9.4.7 /tmp/.ghcup/ghc/9.4.7

RUN rm -rf /root/.ghcup

RUN mkdir -p /root/.ghcup/bin/stack
RUN mkdir -p /root/.ghcup/ghc

RUN cp -r /tmp/.ghcup/bin/stack /root/.ghcup/bin/stack
RUN cp -r /tmp/.ghcup/ghc/9.4.7 /root/.ghcup/ghc/9.4.7

RUN rm -rf /tmp/.ghcup

RUN rm -rf \
    /root/.stack/programs \
    /root/.stack/setup-exe-cache \
    /root/.stack/indices \
    /root/.stack/build-plan \
    /root/.stack/pantry

RUN rm -rf /root/.cabal

FROM ghcr.io/edulinq/grader.python:0.1.0.2-alpine3.20.3 AS final-stage

RUN apk update

RUN apk add --no-cache \
    libffi \
    gmp \
    ncurses \
    zlib

COPY --from=build-stage / /

ENV HOME="/root"
ENV STACK_ROOT=/root/.stack

RUN echo "PATH=\$HOME/.local/bin:\$HOME/.ghcup/bin:\$HOME/.cabal/store/bin:\$PATH" >> $HOME/.bashrc
ENV PATH="$HOME/.local/bin:$HOME/.ghcup/bin:$HOME/.cabal/store/bin:$PATH"

# Install GHC for the stack.yaml resolver.
# RUN stack config set system-ghc --global true
# RUN stack build --resolver=${STACK_RESOLVER} --only-dependencies --jobs=1

# RUN stack build --jobs=1

WORKDIR /autograder/work
