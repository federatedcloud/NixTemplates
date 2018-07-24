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

Singularity is like a Docker container, but without process isolation
(at least [by default](https://www.sylabs.io/guides/2.5.1/user-guide/appendix.html?highlight=containall#singularity-action-flags)).
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


## Switching the base image

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

You may need to  make a separate copy or clone of the repo and checkout out the 
`hash` corresponding to the `hash` in `FROM nix_${BASEOS}_base:hash` in 
`Docker/OpenMPI/Dockerfile`, and build the base as specified in the next step,
assuming you can't pull it from a Docker registry such as DockerHub.


## nix_base

### Docker

#### Building and Running

Make sure to subsitute the appropriate image name in the second command
(check your image list with `docker images | head`).

```bash
source build-base.sh
docker run -i -t nix_alpine_base:abbaed5833f75be43892ccfc5999bd8f03f9583b_testing /bin/sh
```


### Singularity

Choose one of the alternatives below (running from Singularity Hub or Building and Running).

#### Running from Singularity Hub

First visit the [collection](https://www.singularity-hub.org/collections/1220) associated
with this repository on Singularity Hub. You'll notice that the Tag (Branch) may be truncated
due to the fact that we use the full commit hash. To see the full hash, click on the "Complete"
button under the "Status" column for a recent base image, e.g., an image starting with 
`nix_alpine_base_` under the "Tag (Branch)" column. 


```bash
singularity image.create nix-overlay.img
singularity run --contain --overlay nix-overlay.img shub://federatedcloud/NixTemplates:nix_alpine_base_82b5d9a742ad593a353f6160bce846227a0f4e4d
```

#### Building And Running

```bash
rm nix*base*.img
./build-base-singularity.sh
singularity image.create nix-base-overlay.img
singularity run --contain --overlay nix-base-overlay.img nix_alpine_base_82b5d9a742ad593a353f6160bce846227a0f4e4d.img
```

**Note:** If you rebuild the image, you will likely need to either delete or move the old
image to another location, unless the git commit has change, in which case the image filename
changes automatically.

**Important note:** If you update a given singularity image, you will also 
likely need to create a new overlay image to go along with it, otherwise you 
risk undefined behavior.

### Testing Nix

Once you have build an image and started a container as above, you can test it out by installing
your favorite tool (for instance ripgrep's `rg` command) into your environment using Nix:

```bash
nix-env -i ripgrep
```

## nix_openmpi

### Docker

####  Setting up ssh

1. `cd Base/OpenMPI/`
2. `mkdir ssh`
3. `cd ssh && ssh-keygen -t rsa -f id_rsa.mpi -N '' && cd ..`
4. `echo "StrictHostKeyChecking no" > ssh/config` 
5. `chmod 500 ssh && chmod 400 ssh/* && cd ../..`


**Simple build**

```bash
source build-openmpi.sh 
```

#### Testing OpenMPI

Note this will call the above OpenMPI `build-base.sh`, so no need to do both:

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

### Singularity

Choose one of the alternatives below (running from Singularity Hub or Building and Running).

#### Running from Singularity Hub

See instructions [above](#nix_base) for how to use singularity hub in general with this repository.


```bash
singularity image.create -s 4096 nix-overlay.img
singularity run --contain --overlay nix-overlay.img shub://federatedcloud/NixTemplates:nix_alpine_openmpi_64b6d177a14fe6f8d890e353f4843baf83b41eb5
```


#### Building And Running

```bash
rm *.img
./build-singularity.sh
singularity image.create -s 4096 nix-overlay.img
singularity run --contain --overlay nix-overlay.img nix_alpine_openmpi_84c67648e411aaf6e16f66c059135c680b40ee2f.img
```

#### Testing OpenMPI

You will be dropped into a nix-shell, which in this template, sets up python and releveant libraries
such as mpi4py.

```
mpirun -n 2 python /nixenv/nixuser/mpi4py_benchmarks/all_tests.py
```