#! /bin/bash
hostname=$(uname -n)
kernel=$(uname -s)

# For now, we use specific compiler for each platform.
if [[ ${kernel} =~ Darwin ]] ; then
    compiler="gcc"
else
    compiler="intel"
fi

if [[ ${kernel} =~ Darwin ]] ; then # MacOS
    srcdir_base=$HOME/models
    blddir=$HOME/builds
    if [[ ${compiler} =~ gcc ]] ; then
        source osx-gcc.env
        use_default_templates=true
        mkmf_temp=osx-gcc10.mk
    fi
elif [[ ${kernel} =~ Linux ]] ; then # Linux
    srcdir_base=$HOME/src
    # NOAA Gaea C5
    if [[ ${hostname} =~ ^gaea5 ]] ; then
        blddir=$SCRATCH/$USER/gfdl_o/builds
        if [[ ${compiler} =~ intel ]] ; then
            source ./ncrc5-intel.env
            use_default_templates=true
            mkmf_temp=ncrc5-intel-classic.mk
        fi
    fi
    # NOAA Gaea C6
    if [[ ${hostname} =~ ^gaea6 ]] ; then
        blddir=$SCRATCH/$USER/gfdl/builds
        if [[ ${compiler} =~ intel ]] ; then
            source ./ncrc6.intel23.env
            use_default_templates=false
            mkmf_temp=ncrc6.intel23.mk
        fi
    fi
    # UofM Great Lakes
    if [[ ${hostname} =~ ^gl ]] ; then
        if [[ ${compiler} =~ intel ]] ; then
            source ./greatlakes-intel.env
            use_default_templates=false
            mkmf_temp=greatlakes-intel.mk
        fi
    fi
else
    echo "Warning: kernel not recognized. Exiting..." >&2
    exit 1
fi

# Auxiliary components codebase dir
if [[ ${use_egaux} == true ]] ; then # Use codebases shipped with MOM6-examples
    srcdir_aux=${srcdir_base}/MOM6-examples/src
else
    srcdir_aux=${srcdir_base}
fi

# MOM6 codebase dir
if [[ ${use_egmom6} == true ]] ; then # Use codebase shipped with MOM6-examples
    srcdir_mom=${srcdir_base}/MOM6-examples/src
else
    srcdir_mom=${srcdir_base}
fi

# mkmf codebase dir
if [[ ${use_egmkmf} == true ]] ; then # Use codebases shipped with MOM6-examples
    dir_mkmf=${srcdir_base}/MOM6-examples/src/mkmf
else
    dir_mkmf=${srcdir_base}/mkmf
fi
if [[ ${use_default_templates} == true ]] ; then
    mkmf_temp=${dir_mkmf}/templates/${mkmf_temp}
else
    mkmf_temp=${PWD}/${mkmf_temp}
fi

# make flags
makeflags="NETCDF=3"
if [[ $target =~ "repro" ]] ; then
    makeflags="$makeflags REPRO=1"
fi
if [[ $target =~ "debug" ]] ; then
    makeflags="$makeflags DEBUG=1"
fi

# Return env variables srcdir, dir_mkmf, dir_bld, compiler, mkmf_temp