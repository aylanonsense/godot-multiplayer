# syntax=docker/dockerfile:1

FROM ubuntu:latest
EXPOSE 8817/udp
RUN groupadd --gid 354 serveradmins && \
  useradd --create-home --uid 353 --groups serveradmins serveradmin
USER serveradmin
WORKDIR /home/serveradmin
COPY --chmod=0755 build/linux_server/godot_multiplayer.x86_64 godot_multiplayer.x86_64
COPY --chmod=0755 build/tools/linux_server/dedicated/run_server.sh run_server.sh
ENTRYPOINT ["sh", "run_server.sh"]
