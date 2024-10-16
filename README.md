# MOM6-compile

Quick compile for MOM6

All codes are assumed to stored in `$USER/src`. All builds are placed in `build`.

## Options
* -b: Build. can be `fms`, `mom6oo` or `mom6sis2`
* -n: Name. Name for the build
* -t: Target. Either `repro` or `debug`
* -f: FMS library build name. Required for ocean-only or SIS2 coupled MOM6
* --fms2: Use FMS2 infra for MOM6
* --egaux: Use codebase in MOM6-examples for non-MOM6 components
* --egmom6: Use codebase in MOM6-examples for MOM6
* --egmkmf: Use mkmf in MOM6-examples

## Example: compile FMS1
> ./compile_mom6.sh -b fms -n 201901

## Example: compile MOM6 ocean-only
> ./compile_mom6.sh -b mom6oo -n devgfdl -f 201901

## Example: compile MOM6SIS2
> ./compile_mom6.sh -b mom6sis2 -n devgfdl -f 201901

## Note
If `--egaux` is not used, all required code repos need to be cloned individually, including `FMS`, `coupler`, `atmos_null`, `land_null`, `ice_param`, `icebergs`.