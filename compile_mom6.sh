#! /bin/bash
build=mom6oo
use_eg=False
target=repro
name=""

# Parse the arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -b|--build) build="$2"; shift ;; # Build (fms, mom6oo, mom6sis2 etc)
        -n|--name) name="$2"; shift ;;  # Set the filename
        -e|--examples) use_eg=true ;;       # Use MOM6-examples code
        -t|--target) target="$2"; shift ;;  # Target
        -f|--fms) fms="$2"; shift ;;  # FMS library tag
        --) shift; break ;;  # End of all options
        -*|--*) echo "Unknown option $1" >&2; exit 1 ;;
        *) echo "Unknown parameter $1" >&2; exit 1 ;;
    esac
    shift
done

source ./set_env.sh

# create build directory
if [[ ${build} =~ fms ]] ; then # FMS
    bld_name="libfms.a"
    bld_subdir="FMS"
elif [[ ${build} =~ ^mom6 ]] ; then # MOM6
    export dir_fms=${blddir}/FMS/${fms}/${compiler}/${target}
    bld_name="MOM6"
    if [[ ${build} =~ mom6oo ]] ; then # ocean only
        bld_subdir="MOM6/ocean_only"
    elif [[ ${build} =~ mom6sis2 ]] ; then # ice_ocean
        bld_subdir="MOM6/ice_ocean_SIS2"
    fi
else
    echo "Warning: --build not recognized. Exiting..." >&2
    exit 1
fi

dir_bld=${blddir}/${bld_subdir}/${name}/${compiler}/${target}
mkdir -p ${dir_bld}
cd ${dir_bld}

echo "Use source files in "${srcdir}
echo "Build model in "${dir_bld}

# mkmf stuff
rm -f path_names

if [[ ${build} =~ fms ]] ; then # FMS
    ${dir_mkmf}/bin/list_paths -l ${srcdir}/FMS
    ${dir_mkmf}/bin/mkmf -t ${mkmf_temp} -p ${bld_name} -c '-Duse_libMPI -Duse_netCDF' path_names
elif [[ ${build} =~ ^mom6oo ]] ; then # MOM6 ocean only
    ${dir_mkmf}/bin/list_paths -l "${srcdir}/MOM6/config_src/{infra/FMS1,memory/dynamic_symmetric,drivers/solo_driver,external} \
                                   ${srcdir}/MOM6/src/{*,*/*}"
    ${dir_mkmf}/bin/mkmf -t ${mkmf_temp} -p ${bld_name} -o '-I${dir_fms}' -l '-L${dir_fms} -lfms' path_names
elif [[ ${build} =~ mom6sis2 ]] ; then # MOM6 ice_ocean
    ${dir_mkmf}/bin/list_paths -l "${srcdir}/MOM6/config_src/{infra/FMS1,memory/dynamic_symmetric,drivers/FMS_cap,external} \
                                   ${srcdir}/MOM6/src/{*,*/*} \
                                   ${srcdir}/{coupler,atmos_null,land_null,ice_param,icebergs/src,SIS2,FMS/coupler,FMS/include}"
    ${dir_mkmf}/bin/mkmf -t ${mkmf_temp} -p ${bld_name} -o '-I${dir_fms}' -l '-L${dir_fms} -lfms' -c '-Duse_AM3_physics -D_USE_LEGACY_LAND_'  path_names
fi
# there is a problem with mkmf interpretting variables, so mkmfopt="-o '-I${dir_fms}' -l '-L${dir_fms} -lfms'" does not work

make ${makeflags} ${bld_name} -j

echo ${dir_bld}


