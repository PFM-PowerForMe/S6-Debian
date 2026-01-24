FROM ghcr.io/pfm-powerforme/s6:latest AS s6
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

ENV S6_VERSION=$TAG \
     S6_LOGGING_SCRIPT="n2 s1000000 T" \
     DEBIAN_FRONTEND=noninteractive \
     TZ="Asia/Shanghai" \
     LANG="C.UTF-8" \
     TERM="xterm-256color"
COPY rootfs/ /
RUN mkdir -pv /etc/s6-overlay/init-data/ && mkdir -pv /etc/s6-overlay/scripts
RUN chmod +x /pfm/bin/fix_env && chmod +x /pfm/bin/fpm_init
RUN /pfm/bin/fpm_init
COPY --from=s6 / /
RUN /pfm/bin/fix_env

# 运行时
FROM scratch AS runtime
ARG TAG
ENV PATH="/command:/pfm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
     S6_VERSION=$TAG \
     S6_LOGGING_SCRIPT="n2 s1000000 T" \
     DEBIAN_FRONTEND="noninteractive" \
     TZ="Asia/Shanghai" \
     LC_ALL="C.UTF-8" \
     LANG="C.UTF-8" \
     TERM="xterm-256color" \
     COLORTERM="truecolor" \
     EDITOR="nvim" \
     VISUAL="nvim" \
     TMPDIR="/tmp" \
     TEMP="/tmp" \
     TMP="/tmp" \
     HISTCONTROL="ignoredups" \
     HISTSIZE="1000" \
     HISTFILESIZE="1000"

COPY --from=builder / /
# 工具
COPY --from=ghcr.io/pfm-powerforme/cli-envsubst:latest / /
COPY --from=ghcr.io/pfm-powerforme/cli-dasel:latest / /
ENTRYPOINT ["/init"]