# NixTemplates
Several basic templates that are meant to be used as the basis for other Singularity Spec files
using the [Nix](https://nixos.org/nix/) package manager.

## Background

### Nix

Nix provides reproducible builds for software, all the way down to the system level.
This is done by way of keeping track of which commit revision of
[nixpkgs](https://github.com/nixos/nixpkgs) was used at the time of the build.
The user can also pin versions of particular software dependencies by
coding them into the nix expression (think build script).

### Singularity

Singularity is like a Docker container, but without process isolation.
So it isn't a process container, but it is a filesystem container.
Unlike Docker, Singularity provides a non-layered filesystem. This may
have benefits for reproducibility, but also means increased file size if
a user is building multiple image files based on other singularity images.

### Nix and Singularity

Nix wouldn't work well with layering anyway: one benefit of nix is the nix-store,
which is a local store on the system which puts all builds of software that
are hashed based on the nix expression being used to build the software, and any
inputs to that nix expression (so you can have multiple alternative builds of the
same software). A single Singularity image, that holds a custom nix expression,
should be ideal to build an individual image for a particular use case, or even
multiple use cases: multiple use cases can be packaged in a single Singularity
image and separated by using different nix expressions: they all share the same
nix store, so when there are common dependencies, no file system redundancy occurs.


In short, Nix provides build-level customization and reproducibility, which is important
for future work on the project to proceed smooth, whereas Singularity provides
an archive of the existing build state, that is important for both immediate usage,
and as a last resort for users who can't get the build procedure to work down the
road for some unforseen reason.

An advantage of using Nix is that users can also update their environment in a
reproducible way without needing to change a Dockerfile or Singularity Recipe
and build a new image (which may be inconvenient for some
users): if the user changes the nix expression for a given environment,
any additional packages or modified versions of packages that are already installed
are added to the nix store (`/nix/store`) immediately, and the user can check in their
nix expressions (`.nix` files) to version control as needed.

# Building Images

## Docker

### Switching the base image

Since nix is used for package management, we support
multiple base images: currently Ubuntu and Alpine variants.
To use presets for these, select what you want in the `build.sh`
scripts, e.g., one of:

```
source "alpine_envs.sh"
```

or

```
source "ubuntu_envs.sh"
```

Alpine is the default. You may also wish to create your own variant.

### nix_ubuntu_base

```bash
cd Docker
source build.sh

```

### nix_ubuntu_openmpi

####  Setting up ssh

1. `cd Docker/OpenMPI/`
2. `mkdir ssh`
3. `cd ssh && ssh-keygen -t rsa -f id_rsa.mpi -N '' && cd ..`
4. Create a file called [config](https://github.com/CornellCAC/docker.openmpi/blob/master/ssh/config) and add the line `StrictHostKeyChecking no`
5. `chmod 700 -R ssh`

**Simple build**

```bash
source Docker/OpenMPI/build.sh
```

**Testing OpenMPI**

Note this will call the above OpenMPI `build.sh`, so no need to do both:

```bash
source docker-compose-openmpi.sh up --scale mpi_head=1 --scale mpi_node=3
```

Now from another terminal on the host system: 1) connect to the head node,
2) start the relevant environment with `nix-shell`, and 3) run the mpi demo:

```
docker exec -u nixuser -it nixtemplates_mpi_head_1 /bin/sh
nix-shell . # should be from /nixenv/nixuser, or wherever default.nix was copied to
mpirun -n 2 python /home/nixuser/mpi4py_benchmarks/all_tests.py
```

To stop the container set, just press `Ctrl-C` in the terminal where you ran
`docker-compose-openmpi.sh`.

