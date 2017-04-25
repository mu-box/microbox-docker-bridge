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
        rsync \
        easyrsa \
        openvpn && \
    rm -rf /data/var/db/pkgin/cache

RUN mkdir -p /data/share/nanobox && \
    cp -r /data/share/examples/easyrsa/* /data/share/nanobox && \
    cd /data/share/nanobox && \
    /data/bin/easyrsa init-pki && \
    /data/bin/easyrsa --req-cn="Nanobox" --batch build-ca nopass && \
    /data/bin/easyrsa gen-dh && \
    /data/bin/easyrsa build-server-full server nopass && \
    /data/bin/easyrsa build-client-full client1 nopass

# Own all gonano files
RUN chown -R gonano:gonano /data

# Install hooks
RUN curl \
      -f \
      -k \
      https://s3.amazonaws.com/tools.nanobox.io/hooks/bridge-stable.tgz \
        | tar -xz -C /opt/nanobox/hooks

# Download hooks md5 (used to perform updates)
RUN curl \
      -f \
      -k \
      -o /var/nanobox/hooks.md5 \
      https://s3.amazonaws.com/tools.nanobox.io/hooks/bridge-stable.md5

WORKDIR /data

# Run runit automatically
CMD [ "/opt/gonano/bin/nanoinit" ]
