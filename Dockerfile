FROM edulinq/autograder.python:0.0.3

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

RUN apt-get clean

WORKDIR /autograder/work

# Add custom stack.yaml for shared dependencies.
COPY stack.yaml /autograder/work/stack.yaml
COPY dummy-package /autograder/work/dummy-package/

RUN mkdir ~/.ghcup
RUN mkdir ~/.ghcup/bin

RUN curl -o ~/ghcup https://downloads.haskell.org/~ghcup/$(uname -m)-linux-ghcup && \
    chmod +x ~/ghcup && \
    mv ~/ghcup ~/.ghcup/bin/

RUN echo "PATH=\"/root/.local/bin:$PATH\"" >> .bashrc
RUN echo "PATH=\"/root/.ghcup/bin:$PATH\"" >> .bashrc

ENV PATH="/root/.local/bin:/root/.ghcup/bin:$PATH"

# [Choice] GHC version: recommended, latest, 9.2, 9.0, 8.10, 8.8, 8.6
ARG GHC_VERSION=9.4.7
ARG STACK_RESOLVER=lts-21.14

RUN ghcup install ghc "${GHC_VERSION}" --set \
    && ghcup install cabal recommended --set \
    && ghcup install stack recommended --set \
    && cabal update

# Install GHC for the stack.yaml resolver.
RUN stack config set system-ghc --global true
RUN stack install --resolver=${STACK_RESOLVER}
RUN stack build
