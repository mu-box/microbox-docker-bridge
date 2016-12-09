FROM nanobox/runit

# Create directories
RUN mkdir -p \
  /var/log/gonano \
  /var/nanobox \
  /opt/nanobox/hooks

# Install ipvsadm, bridge-utils, nginx, and rsync
RUN apt-get update -qq && \
    apt-get install -y iputils-ping iproute2 && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# Install binaries
RUN rm -rf /data/var/db/pkgin && \
    /data/bin/pkgin -y up && \
    /data/bin/pkgin -y in \
        easyrsa \
        openvpn && \
    rm -rf /data/var/db/pkgin/cache

# Install hooks
RUN curl \
      -f \
      -k \
      https://d1ormdui8qdvue.cloudfront.net/hooks/bridge-stable.tgz \
        | tar -xz -C /opt/nanobox/hooks

# Download hooks md5 (used to perform updates)
RUN curl \
      -f \
      -k \
      -o /var/nanobox/hooks.md5 \
      https://d1ormdui8qdvue.cloudfront.net/hooks/bridge-stable.md5

# Run runit automatically
CMD [ "/opt/gonano/bin/nanoinit" ]
