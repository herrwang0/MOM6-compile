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
    srcdir=$HOME/models
    blddir=$HOME/builds
    if [[ ${compiler} =~ gcc ]] ; then
        source osx-gcc.env
        use_default_templates=True
        mkmf_temp=osx-gcc10.mk
    fi
elif [[ ${kernel} =~ Linux ]] ; then # Linux
    srcdir=$HOME/src
    blddir=$SCRATCH/builds
    # NOAA Gaea C5
    if [[ ${hostname} =~ ^gaea5 ]] ; then
        if [[ ${compiler} =~ intel ]] ; then
            source ncrc5-intel.env
            use_default_templates=True
            mkmf_temp=ncrc5-intel-classic.mk
        fi
    fi
    # NOAA Gaea C6
    if [[ ${hostname} =~ ^gaea6 ]] ; then
        if [[ ${compiler} =~ intel ]] ; then
            source ncrc6-intel.env
            use_default_templates=True
            mkmf_temp=ncrc6-intel-classic.mk
        fi
    fi
    # UofM Great Lakes
    if [[ ${hostname} =~ ^gl ]] ; then
        if [[ ${compiler} =~ intel ]] ; then
            source greatlakes-intel.env
            use_default_templates=False
            mkmf_temp=greatlakes-intel.mk
        fi
    fi
else
    echo "Warning: kernel not recognized. Exiting..." >&2
    exit 1
fi

# Use codes shipped with MOM6-examples
if ${use_eg} ; then
    srcdir=${srcdir}/MOM6-examples/src
fi

# mkmf
dir_mkmf=${srcdir}/mkmf
if ${use_default_templates} ; then
    mkmf_temp=${dir_mkmf}/templates/${mkmf_temp}
fi

# make flags
makeflags="NETCDF=3"
if [[ $target =~ "repro" ]] ; then
    makeflags="$makeflags REPRO=1"
fi
if [[ $target =~ "debug" ]] ; then
    makeflags="$makeflags DEBUG=1"
fi