# syntax=docker/dockerfile:1

FROM ubuntu:latest
ARG EXECUTABLE_FILE=builds/godot_multiplayer_dedicated_linux_server.x86_64
ARG RESOURCE_PACK_FILE=builds/godot_multiplayer_dedicated_linux_server.pck
ARG LINUX_CI_DIR=ci/dockerize_dedicated_linux_server
EXPOSE 8817/tcp
EXPOSE 8817/udp
RUN groupadd --gid 354 serveradmins && \
  useradd --create-home --uid 353 --groups serveradmins serveradmin
USER serveradmin
WORKDIR /home/serveradmin
COPY $EXECUTABLE_FILE godot_multiplayer.x86_64
COPY $RESOURCE_PACK_FILE godot_multiplayer.pck
COPY --chmod=0755 $LINUX_CI_DIR/run_dedicated_linux_server.sh run_dedicated_linux_server.sh
ENTRYPOINT ["sh", "run_dedicated_linux_server.sh"]
