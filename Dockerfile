# We use the official edulinq python grader for Ubuntu.
# https://github.com/edulinq/autograder-docker-python/blob/0.1.0.1/ubuntu/Dockerfile
FROM ghcr.io/edulinq/grader.python:0.1.0.2-alpine3.20.3 AS build-stage

ARG GHC_VERSION=9.4.7
ARG STACK_RESOLVER=lts-21.14

ENV HOME="/root"

RUN apk update

RUN apk add --no-cache \
    build-essential \
    curl \
    libffi-dev \
    libffi8ubuntu1 \
    libgmp-dev \
    libgmp10 \
    libncurses-dev \
    libncurses5 \
    libtinfo5 \
    zlib1g-dev

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
RUN rm -rf /root/.ghcup
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
    libffi8 \
    libgmp10 \
    libncurses5 \
    libtinfo5 \
    zlib1g

RUN apk clean
RUN rm -rf /var/lib/apt/lists/*

# COPY --from=build-stage /root/.ghcup /root/.ghcup
# COPY --from=build-stage /root/.cabal /root/.cabal
COPY --from=build-stage /root/.stack /root/.stack
COPY --from=build-stage /autograder/work/.stack-work/install /autograder/work/.stack-work/install

ENV HOME="/root"
ENV STACK_ROOT=/root/.stack

RUN echo "PATH=\$HOME/.local/bin:$PATH" >> $HOME/.bashrc
ENV PATH="$HOME/.local/bin:$PATH"

WORKDIR /autograder/work
