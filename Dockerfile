FROM eclipse-temurin:25-jre-noble@sha256:b4c93a50fc67612798db73d68ca3b0ee4ebdd51736e59cca370e689b9797037e as build

RUN apt-get update && apt-get -y install \
 curl \
 unzip

ARG TARGETARCH

RUN if [ "${TARGETARCH}" = "amd64" ]; then export IMAGEIO="linux-x86_64.zip"; else export IMAGEIO="ImageIOJars.zip"; fi \
 && curl -LOsS https://raw.githubusercontent.com/johnperry/CTP/master/products/CTP-installer.jar \
 && curl -o ImageIO-arch.zip -LsS https://raw.githubusercontent.com/RSNA/mirc.rsna.org/main/ImageIO/${IMAGEIO}

RUN mkdir -p /JavaPrograms/ext /JavaPrograms/lib \
 && unzip ImageIO-arch.zip -d /JavaPrograms/ext \
 && mv /JavaPrograms/ext/*.so /JavaPrograms/lib ||: \
 && unzip CTP-installer.jar -d /JavaPrograms

FROM eclipse-temurin:25-jre-noble@sha256:b4c93a50fc67612798db73d68ca3b0ee4ebdd51736e59cca370e689b9797037e

COPY --from=build /JavaPrograms/ /JavaPrograms/

COPY ./ /

RUN ln -sfr /JavaPrograms/config/config.xml /JavaPrograms/CTP/config.xml \
 && ln -sfr /JavaPrograms/config/index.html /JavaPrograms/CTP/ROOT/index.html \
 && ln -sfr /JavaPrograms/config/keystore /JavaPrograms/CTP/keystore \
 && ln -sfr /JavaPrograms/config/users.xml /JavaPrograms/CTP/users.xml

# java -XshowSettings:properties -version
ENV CLASSPATH="/JavaPrograms/CTP/libraries:/JavaPrograms/ext" \
 LD_LIBRARY_PATH="/JavaPrograms/lib" \
 TZ="UTC"

WORKDIR /JavaPrograms/CTP
EXPOSE 8080/tcp
CMD ["java","-jar","Runner.jar"]
