with import <nixpkgs> {};
# with pkgs.python36Packages;
stdenv.mkDerivation {
  name = "impurePythonEnv";
  buildInputs = [
    python36Full
    python36Packages.mpi4py
    python36Packages.numpy    
    python36Packages.pip
    python36Packages.scipy
    python36Packages.virtualenv    
  ];
  src = null;
  shellHook = ''
    export LANG=en_US.UTF-8
    export PATH="$HOME/openmpi/bin:$PATH"
    export LD_LIBRARY_PATH="$HOME/openmpi/lib:$LD_LIBRARY_PATH"
  '';
}
