FROM gliderlabs/alpine:3.1

#ENV VERSION=v0.10.38 CMD=node DOMAIN=nodejs.org CFLAGS="-D__USE_MISC"
ENV VERSION=v0.12.3 CMD=node DOMAIN=nodejs.org
#ENV VERSION=v2.0.1 CMD=iojs DOMAIN=iojs.org NO_NPM_UPDATE=true

# For base builds
#ENV CONFIG_FLAGS="--without-npm" RM_DIRS=/usr/include
#ENV CONFIG_FLAGS="--fully-static --without-npm" DEL_PKGS="libgcc libstdc++" RM_DIRS=/usr/include

RUN apk-install curl make cmake gcc g++ python paxctl libgcc libstdc++ && \
  curl -sSL https://${DOMAIN}/dist/${VERSION}/${CMD}-${VERSION}.tar.gz | tar -xz && \
  cd /${CMD}-${VERSION} && \
  ./configure --prefix=/usr ${CONFIG_FLAGS} && \
  make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  make install && \
  paxctl -cm /usr/bin/${CMD} && \
  cd / && \
  if [ -x /usr/bin/npm -a -z "$NO_NPM_UPDATE" ]; then \
    npm install -g npm && \
    find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
  fi && \
  apk del curl make gcc g++ python paxctl ${DEL_PKGS} && \
  rm -rf /etc/ssl /${CMD}-${VERSION} ${RM_DIRS} \
    /usr/share/man /tmp/* /root/.npm /root/.node-gyp \
    /usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html
