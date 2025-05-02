# We use the official edulinq python grader for Alpine.
# https://github.com/edulinq/autograder-docker-python/blob/0.1.0.2/alpine/Dockerfile
FROM ghcr.io/edulinq/grader.python:0.1.0.2-alpine3.20.3 AS build-stage

ARG GHC_VERSION=9.4.7
ARG STACK_RESOLVER=lts-21.14

ENV HOME="/root"

RUN apk update

# Required install packages for ghcup on Alpine
# https://www.haskell.org/ghcup/install/#linux-alpine
RUN apk add --no-cache \
    binutils-gold \
    curl \
    gcc \
    g++ \
    gmp \
    gmp-dev \
    libc-dev \
    libffi \
    libffi-dev \
    make \
    musl \
    musl-dev \
    ncurses \
    ncurses-dev \
    perl \
    tar \
    xz \
    zlib \
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

# Remove unnecessary build artifacts.
RUN stack purge
RUN rm -rf \
    $HOME/.stack/logs \
    $HOME/.stack/build-plan \
    $HOME/.stack/indices \
    $HOME/.stack/pantry \
    $HOME/.stack/setup-exe-cache

RUN rm -rf \
    $HOME/.cabal/logs \
    $HOME/.cabal/packages \
    $HOME/.cache/cabal

RUN rm -rf \
    $HOME/.ghcup/cache \
    $HOME/.ghcup/ghc/${GHC_VERSION}/share/doc \
    $HOME/.ghcup/logs \
    $HOME/.ghcup/tmp

FROM ghcr.io/edulinq/grader.python:0.1.0.2-alpine3.20.3 AS final-stage

COPY --from=build-stage / /

ENV HOME="/root"
ENV STACK_ROOT=$HOME/.stack

RUN echo "PATH=\$HOME/.local/bin:\$HOME/.ghcup/bin:\$HOME/.cabal/store/bin:\$PATH" >> $HOME/.bashrc
ENV PATH="$HOME/.local/bin:$HOME/.ghcup/bin:$HOME/.cabal/store/bin:$PATH"

WORKDIR /autograder/work

# Pre-install and compile dependencies.
RUN stack config set system-ghc --global true
RUN stack build --only-dependencies
