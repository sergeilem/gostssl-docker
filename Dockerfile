FROM ghcr.io/sergeilem/openssl as build

RUN apt update && apt install -y build-essential gcc wget git cmake unzip perl

ENV OPENSSL_ROOT_DIR=/usr/gostssl
WORKDIR /usr/src
RUN git clone https://github.com/gost-engine/engine.git gostengine
WORKDIR /usr/src/gostengine

RUN mkdir build
WORKDIR /usr/src/gostengine/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DOPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR} -DOPENSSL_LIBRARIES=${OPENSSL_ROOT_DIR}/lib -DOPENSSL_ENGINES_DIR=${OPENSSL_ROOT_DIR}/lib/engines-3 ..
RUN cmake --build . --config Release && cmake --build . --target install --config Release

# final stage
FROM ubuntu:latest
ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
COPY --from=build /usr/gostssl /usr/gostssl
