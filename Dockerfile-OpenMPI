ARG BASEOS
FROM nix_${BASEOS}_base:44cce3d948f38408bc97addb699ba02cc479df8e

USER root
ARG ADDUSER

COPY OpenMPI/config.nix $HOME/.config/nixpkgs/
COPY OpenMPI/dev-env.nix $ENVSDIR/
COPY Utils/persist-env.sh $ENVSDIR/
RUN chown -R $nixuser:$nixuser $ENVSDIR

#
# Initialize environment a bit for faster container spinup/use later
#
USER $nixuser
RUN $nixenv && cd /tmp && sh $ENVSDIR/persist-env.sh $ENVSDIR/dev-env.nix
#

USER root

#
# The below method isn't ideal, as it could break - better to copy in an sshd_config file
# or somehow use nix to configure sshd
# sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
#
# alternatively ...:
# TODO: write a script to check if PermitRootLogin is already set, and replace it if so, else add it
#
ENV SSHD_PATH ""
RUN SSHD_PATH=$(su -c "$nixenv && nix-build '<nixpkgs>' --no-build-output --no-out-link -A openssh" "${nixuser:?}") && \
  mkdir -p /etc/ssh && cp "$SSHD_PATH/etc/ssh/sshd_config" /etc/ssh/sshd_config && \
  mkdir /var/run/sshd && \
  printf "PermitRootLogin yes\n" >> /etc/ssh/sshd_config && \
  id -u sshd || ${ADDUSER} sshd && \
  mkdir -p /var/empty/sshd/etc && \
  cd /var/empty/sshd/etc && \
  ln -s /etc/localtime localtime
  
USER $nixuser


# ------------------------------------------------------------
# Set-Up SSH with our Github deploy key
# ------------------------------------------------------------

ENV SSHDIR ${HOME}/.ssh/

RUN mkdir -p ${SSHDIR}

ADD OpenMPI/ssh/config ${SSHDIR}/config
ADD OpenMPI/ssh/id_rsa.mpi ${SSHDIR}/id_rsa
ADD OpenMPI/ssh/id_rsa.mpi.pub ${SSHDIR}/id_rsa.pub
ADD OpenMPI/ssh/id_rsa.mpi.pub ${SSHDIR}/authorized_keys

USER root

RUN chmod -R 600 ${SSHDIR}* && \
    chown -R ${nixuser}:${nixuser} ${SSHDIR}

# ------------------------------------------------------------
# Configure OpenMPI
# ------------------------------------------------------------

RUN rm -fr ${HOME}/.openmpi && mkdir -p ${HOME}/.openmpi
ADD OpenMPI/default-mca-params.conf ${HOME}/.openmpi/mca-params.conf
RUN chown -R ${nixuser}:${nixuser} ${HOME}/.openmpi

# ------------------------------------------------------------
# Copy MPI4PY example scripts
# ------------------------------------------------------------

ENV TRIGGER 1

ADD OpenMPI/mpi4py_benchmarks ${HOME}/mpi4py_benchmarks
RUN chown -R ${nixuser}:${nixuser} ${HOME}/mpi4py_benchmarks

#Copy this last to prevent rebuilds when changes occur in them:
COPY OpenMPI/entrypoint* $ENVSDIR/
COPY OpenMPI/default.nix $ENVSDIR/

RUN chown $nixuser:$nixuser $ENVSDIR/entrypoint
ENV PATH="${PATH}:/usr/local/bin"

EXPOSE 22
ENTRYPOINT ["/bin/sh", "./entrypoint"]
