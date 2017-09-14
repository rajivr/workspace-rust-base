FROM lambdalinux/baseimage-amzn:2017.03-004

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
  # install rust-stable
  curl -L https://static.rust-lang.org/dist/rust-1.20.0-x86_64-unknown-linux-gnu.tar.gz -o /tmp/docker-build/rust-1.20.0-x86_64-unknown-linux-gnu.tar.gz && \
  curl -L https://static.rust-lang.org/dist/rustc-1.20.0-src.tar.gz -o /tmp/docker-build/rustc-1.20.0-src.tar.gz && \
  pushd /tmp/docker-build && \
  tar zxvf rust-1.20.0-x86_64-unknown-linux-gnu.tar.gz && \
  pushd rust-1.20.0-x86_64-unknown-linux-gnu && \
  ./install.sh --prefix=/opt/rust-stable && \
  popd && \
  tar zxvf rustc-1.20.0-src.tar.gz && \
  pushd rustc-1.20.0-src && \
  mkdir -p /opt/rust-stable/lib/rustlib/src/rust && \
  mv src /opt/rust-stable/lib/rustlib/src/rust && \
  popd && \
  # install rust-nightly
  curl -L https://static.rust-lang.org/dist/rust-nightly-x86_64-unknown-linux-gnu.tar.gz -o /tmp/docker-build/rust-nightly-x86_64-unknown-linux-gnu.tar.gz && \
  curl -L https://static.rust-lang.org/dist/rustc-nightly-src.tar.gz -o /tmp/docker-build/rustc-nightly-src.tar.gz && \
  pushd /tmp/docker-build && \
  tar zxvf rust-nightly-x86_64-unknown-linux-gnu.tar.gz && \
  pushd rust-nightly-x86_64-unknown-linux-gnu && \
  ./install.sh --prefix=/opt/rust-nightly && \
  popd && \
  tar zxvf rustc-nightly-src.tar.gz && \
  pushd rustc-nightly-src && \
  mkdir -p /opt/rust-nightly/lib/rustlib/src/rust && \
  mv src /opt/rust-nightly/lib/rustlib/src/rust && \
  popd && \
  # rust-stable cargo packages
  rm -rf /tmp/docker-build/.cargo && \
  HOME=/tmp/docker-build PATH=/opt/rust-stable/bin:$PATH /opt/rust-stable/bin/cargo install rustfmt && \
  HOME=/tmp/docker-build PATH=/opt/rust-stable/bin:$PATH /opt/rust-stable/bin/cargo install racer && \
  mv .cargo/bin/* /opt/rust-stable/bin && \
  # rust-nightly cargo packages
  rm -rf /tmp/docker-build/.cargo && \
  HOME=/tmp/docker-build PATH=/opt/rust-nightly/bin:$PATH /opt/rust-nightly/bin/cargo install rustfmt && \
  HOME=/tmp/docker-build PATH=/opt/rust-nightly/bin:$PATH /opt/rust-nightly/bin/cargo install racer && \
  HOME=/tmp/docker-build PATH=/opt/rust-nightly/bin:$PATH /opt/rust-nightly/bin/cargo install clippy && \
  mv .cargo/bin/* /opt/rust-nightly/bin && \
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
