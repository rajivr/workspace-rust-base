FROM lambdalinux/baseimage-amzn:2017.03-002

CMD ["/sbin/my_init"]

COPY [ \
  "./docker-extras/etc-sudoers.d-docker", \
  "/tmp/docker-build/" \
]

RUN \
  # yum
  yum update && \
  yum install gcc48 && \
  yum install sudo && \
  yum install tar && \
  \
  # setup sudo
  usermod -a -G wheel ll-user && \
  cp /tmp/docker-build/etc-sudoers.d-docker /etc/sudoers.d/docker && \
  chmod 440 /etc/sudoers.d/docker && \
  \
  # install rust
  curl -L https://static.rust-lang.org/dist/rust-1.18.0-x86_64-unknown-linux-gnu.tar.gz -o /tmp/docker-build/rust-1.18.0-x86_64-unknown-linux-gnu.tar.gz && \
  curl -L https://static.rust-lang.org/dist/rustc-1.18.0-src.tar.gz -o /tmp/docker-build/rustc-1.18.0-src.tar.gz && \
  pushd /tmp/docker-build && \
  tar zxvf rust-1.18.0-x86_64-unknown-linux-gnu.tar.gz && \
  pushd rust-1.18.0-x86_64-unknown-linux-gnu && \
  ./install.sh && \
  popd && \
  tar zxvf rustc-1.18.0-src.tar.gz && \
  pushd rustc-1.18.0-src && \
  mkdir -p /usr/local/lib/rustlib/src/rust && \
  mv src /usr/local/lib/rustlib/src/rust && \
  popd && \
  HOME=/tmp/docker-build cargo install rustfmt && \
  HOME=/tmp/docker-build cargo install racer && \
  mv .cargo/bin/* /usr/local/bin && \
  su -l ll-user -c "mkdir -p /home/ll-user/work/.cargo" && \
  su -l ll-user -c "ln -sf /home/ll-user/work/.cargo .cargo" && \
  popd && \
  \
  # cleanup
  rm -rf /tmp/docker-build && \
  yum clean all && \
  rm -rf /var/cache/yum/* && \
  rm -rf /tmp/* && \
  rm -rf /var/tmp/*
