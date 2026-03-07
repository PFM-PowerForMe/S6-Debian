# 构建时
FROM docker.io/library/debian:stable-slim AS builder
ARG REPO
# eg. amd64 | arm64
ARG ARCH
# eg. x86_64 | aarch64
ARG CPU_ARCH
ARG TAG
# eg. latest
ARG IMAGE_VERSION
ENV REPO=$REPO \
     ARCH=$ARCH \
     CPU_ARCH=$CPU_ARCH \
     TAG=$TAG \
     IMAGE_VERSION=$IMAGE_VERSION

RUN apt-get -y update && \
     apt-get -y --no-install-recommends install lsb-release apt-transport-https ca-certificates curl wget xz-utils && \
     mkdir -pv /s6/
RUN wget -O /tmp/s6-overlay-noarch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/${TAG}/s6-overlay-noarch.tar.xz && \
     wget -O /tmp/s6-overlay-${CPU_ARCH}.tar.xz https://github.com/just-containers/s6-overlay/releases/download/${TAG}/s6-overlay-${CPU_ARCH}.tar.xz && \
     wget -O /tmp/s6-overlay-symlinks-arch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/${TAG}/s6-overlay-symlinks-arch.tar.xz && \
     wget -O /tmp/s6-overlay-symlinks-noarch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/${TAG}/s6-overlay-symlinks-noarch.tar.xz && \
     tar -C /s6/ -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
     tar -C /s6/ -Jxpf /tmp/s6-overlay-${CPU_ARCH}.tar.xz && \
     tar -C /s6/ -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz && \
     tar -C /s6/ -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz && \
     rm /tmp/s6-overlay-noarch.tar.xz && \
     rm /tmp/s6-overlay-${CPU_ARCH}.tar.xz && \
     rm /tmp/s6-overlay-symlinks-arch.tar.xz && \
     rm /tmp/s6-overlay-symlinks-noarch.tar.xz

# RUN wget -O /tmp/syslogd-overlay-noarch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/${TAG}/syslogd-overlay-noarch.tar.xz && \
     # tar -C /s6/ -Jxpf /tmp/syslogd-overlay-noarch.tar.xz && \
     # rm /tmp/syslogd-overlay-noarch.tar.xz

# 运行时
FROM scratch AS runtime
COPY --from=builder /s6/ /