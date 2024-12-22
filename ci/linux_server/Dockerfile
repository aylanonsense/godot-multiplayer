# syntax=docker/dockerfile:1

FROM ubuntu:latest
EXPOSE 8817/tcp
EXPOSE 8817/udp
RUN groupadd --gid 354 serveradmins && \
  useradd --create-home --uid 353 --groups serveradmins serveradmin
USER serveradmin
WORKDIR /home/serveradmin
COPY --chmod=0755 builds/linux_server/godot_multiplayer.x86_64 godot_multiplayer.x86_64
COPY --chmod=0755 ci/linux_server/run_linux_server.sh run_linux_server.sh
ENTRYPOINT ["sh", "run_linux_server.sh"]
