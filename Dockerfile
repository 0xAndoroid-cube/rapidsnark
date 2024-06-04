FROM --platform=linux/amd64 ubuntu:jammy 

# Install dependencies
RUN apt-get update
RUN apt-get -y --no-install-recommends install build-essential cmake libgmp-dev libsodium-dev nasm
RUN apt-get -y --no-install-recommends install git curl gnupg
ENV NODE_VERSION=16.13.0
RUN apt install -y ca-certificates
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

COPY ./zkLogin_cpp /app_cpp
RUN apt-get -y --no-install-recommends install nlohmann-json3-dev libgmp-dev nasm

WORKDIR /app_cpp
RUN make

COPY . /app
WORKDIR /app

ENV LD_LIBRARY_PATH=/usr/local/lib:/app/depends/pistache/build/src

RUN npm install
RUN git submodule init
RUN git submodule update
RUN npx task createFieldSources
RUN npx task buildPistache
RUN npx task buildProverServer


WORKDIR /app
RUN chmod +x /app/build/proverServer
CMD ["/app/build/proverServer", "/keys/proving_key.zkey","/app_cpp/"]




