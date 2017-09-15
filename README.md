# Workspace Rust Base

Workspace Rust Base provides rust toolchain and source code in a docker container. Following tools are available &ndash;

* `cargo`
* `cargo-fmt`
* `racer`
* `rls`
* `rust-gdb`
* `rust-lldb`
* `rustc`
* `rustdoc`
* `rustfmt`

## Getting Started

You can pull docker image from Dockerhub.

```
$ docker pull rajivmr/workspace-rust-base
```

Rust requires `.cargo/` directory to be setup correctly. In `workspace-rust-base`, we keep our `.cargo/` directory outside our container and bind mount `/home/ll-user/work` to directory containing `.cargo/`.

The source of the bind mount can be either on docker host or on docker host virtual machine (that is your local Mac, Windows, or Linux).

Assuming `work-rust` is your workspace directory. Create `.cargo/` sub-directory and do `docker run` as follows &ndash;

```
$ cd work-rust
$ mkdir .cargo

$ docker run -d -v `pwd`:/home/ll-user/work -i rajivmr/workspace-rust-base
```

You can verify bind mount is setup correctly using `docker inspect`

```
$ docker inspect -f '{{ json .Mounts }}' <container_name> | jq '.'
[
  {
    "Source": "/Users/username/work-rust",
    "Destination": "/home/ll-user/work",
    "Mode": "",
    RW": true,
    "Propagation": "rprivate"
  }
]
```

That's it! You can now `docker exec` into the container and start using Rust.

```
$ docker exec -t -i <container_name> /sbin/setuser ll-user /bin/bash

[ll-user@c941cbbd96f7 /]$ cd
[ll-user@c941cbbd96f7 ~]$ ls -la

[...]

lrwxrwxrwx 1 ll-user ll-user   25 Jul  5 13:58 .cargo -> /home/ll-user/work/.cargo
drwxr-xr-x 3 ll-user ll-user 4096 Jul  6 03:20 work

[ll-user@c941cbbd96f7 ~]$ ls /opt/rust-stable/bin/
cargo  cargo-fmt  racer  rustc  rustdoc  rustfmt  rust-gdb  rust-lldb

[ll-user@c941cbbd96f7 ~]$ ls /opt/rust-nightly/bin/
cargo  cargo-clippy  cargo-fmt  racer  rls  rustc  rustdoc  rustfmt  rust-gdb  rust-lldb
```

### Building `workspace-rust-base`

```
$ cd workspace-rust-base
$ docker build -t workspace-rust-base .
```
