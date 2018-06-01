FROM nix_ubuntu_base:fc91f40cf24fff6ee19d5ca49562b831a819ea76_testing

ARG BASEDIR

COPY $BASEDIR/config.nix $HOME/.config/nixpkgs/
COPY $BASEDIR/dev-env.nix $ENVSDIR/
COPY persist-env.sh $ENVSDIR/

#
# Initialize environment a bit for faster container spinup/use later
#
RUN $nixenv && cd /tmp && $ENVSDIR/persist-env.sh $ENVSDIR/dev-env.nix
#

USER $nixuser

# ------------------------------------------------------------
# Set-Up SSH with our Github deploy key
# ------------------------------------------------------------

ENV SSHDIR ${HOME}/.ssh/

RUN mkdir -p ${SSHDIR}

ADD $BASEDIR/ssh/config ${SSHDIR}/config
ADD $BASEDIR/ssh/id_rsa.mpi ${SSHDIR}/id_rsa
ADD $BASEDIR/ssh/id_rsa.mpi.pub ${SSHDIR}/id_rsa.pub
ADD $BASEDIR/ssh/id_rsa.mpi.pub ${SSHDIR}/authorized_keys

USER root

RUN chmod -R 600 ${SSHDIR}* && \
    chown -R ${USER}:${USER} ${SSHDIR}

# ------------------------------------------------------------
# Configure OpenMPI
# ------------------------------------------------------------

RUN rm -fr ${HOME}/.openmpi && mkdir -p ${HOME}/.openmpi
ADD $BASEDIR/default-mca-params.conf ${HOME}/.openmpi/mca-params.conf
RUN chown -R ${USER}:${USER} ${HOME}/.openmpi

# ------------------------------------------------------------
# Copy MPI4PY example scripts
# ------------------------------------------------------------

ENV TRIGGER 1

ADD $BASEDIR/mpi4py_benchmarks ${HOME}/mpi4py_benchmarks
RUN chown -R ${USER}:${USER} ${HOME}/mpi4py_benchmarks

#Copy this last to prevent rebuilds when changes occur in them:
COPY $BASEDIR/entrypoint $ENVSDIR/
COPY $BASEDIR/default.nix $ENVSDIR/

RUN chown $nixuser:$nixuser $ENVSDIR/entrypoint
USER $nixuser
ENV PATH="${PATH}:/usr/local/bin"

EXPOSE 22
ENTRYPOINT "./entrypoint"
