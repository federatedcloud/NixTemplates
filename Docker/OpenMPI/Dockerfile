FROM nix_ubuntu_base:latest

#
# Initialize environment a bit for faster container spinup/use later
#
RUN $nixenv && cd /tmp && $ENVSDIR/persist-env.sh $ENVSDIR/dev-env.nix
#
RUN $nixenv && echo `which sbt`
#
RUN $nixenv && printf 'exit\n' | sbt -Dsbt.global.base=.sbt -Dsbt.boot.directory=.sbt -Dsbt.ivy.home=.ivy2 && \
  rsync -a $HOME/ $HOME_TEMPLATE


#Copy this last to prevent rebuilds when changes occur in entrypoint:
COPY ./entrypoint $ENVSDIR/
USER root

# TODO: remove the python/pip bits if/when working in nix:
# RUN wget https://bootstrap.pypa.io/get-pip.py && python3.6 get-pip.py && \
#   python3.6 -m pip install pipenv --upgrade
  
RUN chown $nixuser:$nixuser $ENVSDIR/entrypoint
USER $nixuser
ENV PATH="${PATH}:/usr/local/bin"
