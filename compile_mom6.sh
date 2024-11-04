#! /bin/bash
build=mom6oo
name=""
target=repro
use_fms2=false
use_egaux=false
use_egmom6=false
use_egmkmf=false

# Parse the arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -b|--build) build="$2"; shift ;; # Build (fms, mom6oo, mom6sis2 etc)
        -n|--name) name="$2"; shift ;;  # Set the filename
        -t|--target) target="$2"; shift ;;  # Target: repro, debug
        -f|--fms) fms="$2"; shift ;;  # FMS library tag
        --fms2) use_fms2=true ;; # Use FMS2
        --nonsym) use_nonsym=true ;; # Use nonsymmetric dynamic memory
        --egaux) use_egaux=true ;; # Use MOM6-examples code for non-MOM6 component
        --egmom6) use_egmom6=true ;; # Use MOM6-examples code for MOM6
        --egmkmf) use_egmkmf=true ;; # Use MOM6-examples code for mkmf
        --) shift; break ;;  # End of all options
        -*|--*) echo "Unknown option $1" >&2; exit 1 ;;
        *) echo "Unknown parameter $1" >&2; exit 1 ;;
    esac
    shift
done

#------------------------------------------------------------------------------
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

# FMS version for MOM6
if [[ ${use_fms2} == true ]] ; then
    fmsver='FMS2'
else
    fmsver='FMS1'
fi

# Dynamic memory type for MOM6
if [[ ${use_nonsym} == true ]] ; then
    mem='dynamic_nonsymmetric'
else
    mem='dynamic_symmetric'
fi

# make flags
makeflags="NETCDF=3"
if [[ $target =~ "repro" ]] ; then
    makeflags="$makeflags REPRO=1"
fi
if [[ $target =~ "debug" ]] ; then
    makeflags="$makeflags DEBUG=1"
fi

#------------------------------------------------------------------------------
# create build directory
if [[ ${build} =~ fms ]] ; then # FMS
    bld_name="libfms.a"
    bld_subdir="FMS"
    echo "Build FMS, use source files in "${srcdir_aux}
elif [[ ${build} =~ ^mom6 ]] ; then # MOM6
    export dir_fms=${blddir}/FMS/${fms}/${compiler}/${target}
    bld_name="MOM6"
    if [[ ${build} =~ mom6oo ]] ; then # ocean only
        bld_subdir="MOM6/ocean_only"
        echo "Build MOM6 ocean only, use source files in "${srcdir_mom}
    elif [[ ${build} =~ mom6sis2 ]] ; then # ice_ocean
        bld_subdir="MOM6/ice_ocean_SIS2"
        echo "Build MOM6-SIS2, use source files in "${srcdir_mom}
        echo "  and "${srcdir_aux}
    else
        echo "Warning: --build unrecognized MOM6 build. Exiting..." >&2
        exit 1
    fi
else
    echo "Warning: --build not recognized. Exiting..." >&2
    exit 1
fi

dir_bld=${blddir}/${bld_subdir}/${name}/${compiler}/${target}
mkdir -p ${dir_bld}
cd ${dir_bld}
echo "Build model in "${dir_bld}
#------------------------------------------------------------------------------
# mkmf stuff
rm -f path_names

if [[ ${build} =~ fms ]] ; then # FMS
    ${dir_mkmf}/bin/list_paths -l ${srcdir_aux}/FMS
    ${dir_mkmf}/bin/mkmf -t ${mkmf_temp} -p ${bld_name} -c '-Duse_libMPI -Duse_netCDF' path_names
elif [[ ${build} =~ ^mom6oo ]] ; then # MOM6 ocean only
    ${dir_mkmf}/bin/list_paths -l "${srcdir_mom}/MOM6/config_src/{infra/${fmsver},memory/${mem},drivers/solo_driver,external} \
                                   ${srcdir_mom}/MOM6/src/{*,*/*}"
    ${dir_mkmf}/bin/mkmf -t ${mkmf_temp} -p ${bld_name} -o '-I${dir_fms}' -l '-L${dir_fms} -lfms' path_names
elif [[ ${build} =~ mom6sis2 ]] ; then # MOM6 ice_ocean
    ${dir_mkmf}/bin/list_paths -l "${srcdir_mom}/MOM6/config_src/{infra/${fmsver},memory/${mem},drivers/FMS_cap,external} \
                                   ${srcdir_mom}/MOM6/src/{*,*/*} \
                                   ${srcdir_aux}/{coupler,atmos_null,land_null,ice_param,icebergs/src,SIS2,FMS/coupler,FMS/include}"
    ${dir_mkmf}/bin/mkmf -t ${mkmf_temp} -p ${bld_name} -o '-I${dir_fms}' -l '-L${dir_fms} -lfms' -c '-Duse_AM3_physics -D_USE_LEGACY_LAND_'  path_names
fi
# there is a problem with mkmf interpretting variables, so mkmfopt="-o '-I${dir_fms}' -l '-L${dir_fms} -lfms'" does not work

#------------------------------------------------------------------------------
make ${makeflags} ${bld_name} -j

echo ${dir_bld}


