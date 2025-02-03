FROM edulinq/grader.base-ubuntu22.04:0.0.4

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

RUN mkdir -p /autograder/input
# Ensure the directories that the student submission code will move into is created.
# This step allows the `chown` command to properly set permissions.
RUN mkdir -p /autograder/work/00-lambda/tests

RUN useradd --create-home --shell /bin/bash grader

WORKDIR /home/grader

# Add custom stack.yaml for shared dependencies.
COPY stack.yaml /home/grader/stack.yaml
COPY dummy-package /home/grader/dummy-package/

RUN chown -R grader:grader /home/grader
RUN chown -R grader:grader /autograder

USER grader

RUN mkdir ~/.ghcup
RUN mkdir ~/.ghcup/bin

RUN curl -o ~/ghcup https://downloads.haskell.org/~ghcup/$(uname -m)-linux-ghcup && \
    chmod +x ~/ghcup && \
    mv ~/ghcup ~/.ghcup/bin/

RUN echo "PATH=\"/home/grader/.local/bin:$PATH\"" >> .bashrc
RUN echo "PATH=\"/home/grader/.ghcup/bin:$PATH\"" >> .bashrc

ENV PATH="/home/grader/.local/bin:/home/grader/.ghcup/bin:$PATH"

# [Choice] GHC version: recommended, latest, 9.2, 9.0, 8.10, 8.8, 8.6
ARG GHC_VERSION=9.4.7
ARG STACK_RESOLVER=lts-21.14

RUN ~/.ghcup/bin/ghcup install ghc "${GHC_VERSION}" && \
    ~/.ghcup/bin/ghcup set ghc "${GHC_VERSION}" && \
    ~/.ghcup/bin/ghcup install stack && \
    ~/.ghcup/bin/ghcup set stack

# Install GHC for the stack.yaml resolver.
RUN stack install --resolver=${STACK_RESOLVER}
RUN stack build

CMD [ "echo", "CSE 114A Grading Base Image" ]
