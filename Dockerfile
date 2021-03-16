FROM sergeilem/openssl as build

RUN apt update && apt install -y build-essential gcc wget git cmake unzip perl

ENV OPENSSL_ROOT_DIR=/usr/gostssl
WORKDIR /usr/src
RUN git clone https://github.com/gost-engine/engine.git gostengine
WORKDIR /usr/src/gostengine

# should make these patches, otherwise will get cmake build errors, see details: https://github.com/gost-engine/engine/issues/322
RUN sed -i -e 's/^install(TARGETS gostsum gost12sum)/install(TARGETS gostsum gost12sum DESTINATION ${OPENSSL_ENGINES_DIR})/' CMakeLists.txt
RUN sed -i -e 's/^install(TARGETS lib_gost_engine EXPORT GostEngineConfig)/install(TARGETS lib_gost_engine EXPORT GostEngineConfig LIBRARY DESTINATION ${OPENSSL_ENGINES_DIR})/' CMakeLists.txt

RUN mkdir build
WORKDIR /usr/src/gostengine/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DOPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR} -DOPENSSL_LIBRARIES=${OPENSSL_ROOT_DIR}/lib -DOPENSSL_ENGINES_DIR=${OPENSSL_ROOT_DIR}/lib/engines-3 ..
RUN cmake --build . --config Release && cmake --build . --target install --config Release

# final stage
FROM debian:buster-slim
COPY --from=build /usr/gostssl /usr/gostssl
