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

# Remove unnecessary build artifacts.
RUN stack purge
RUN rm -rf \
    /root/.stack/logs \
    /root/.stack/build-plan \
    /root/.stack/indices \
    /root/.stack/pantry \
    /root/.stack/setup-exe-cache

RUN rm -rf \
    /root/.cabal/logs \
    /root/.cabal/packages \
    /root/.cache/cabal

RUN rm -rf \
    /root/.ghcup/cache \
    /root/.ghcup/ghc/9.4.7/share/doc \
    /root/.ghcup/logs \
    /root/.ghcup/tmp

FROM ghcr.io/edulinq/grader.python:0.1.0.2-alpine3.20.3 AS final-stage

COPY --from=build-stage / /

ENV HOME="/root"
ENV STACK_ROOT=/root/.stack

RUN echo "PATH=\$HOME/.local/bin:\$HOME/.ghcup/bin:\$HOME/.cabal/store/bin:\$PATH" >> $HOME/.bashrc
ENV PATH="$HOME/.local/bin:$HOME/.ghcup/bin:$HOME/.cabal/store/bin:$PATH"

WORKDIR /autograder/work

# Install GHC for the stack.yaml resolver.
RUN stack config set system-ghc --global true
RUN stack build --only-dependencies
