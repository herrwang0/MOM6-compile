# MOM6-compile

Quick compile for MOM6

All codes are assumed to stored in `$USER/src`. All builds are placed in `build`.

## Options
* -b: Build. can be `fms`, `mom6oo` or `mom6sis2`
* -n: Name. Name for the build
* -t: Target. Either `repro` or `debug`
* -f: FMS library build name. Required for ocean-only or SIS2 coupled MOM6
* --nonsym: Use nonsymmetric dynamic memory
* --fms2: Use FMS2 infra for MOM6
* --eg_aux: Use codebase in MOM6-examples for non-MOM6 components
* --eg_mom6: Use codebase in MOM6-examples for MOM6
* --cefi_aux: Use codebase in CEFI-regional-MOM6 for non-MOM6 components
* --ceif_mom6: Use codebase in CEFI-regional-MOM6 for MOM6
* --aux_mkmf: Use mkmf from either MOM6-examples or CEFI-regional-MOM6

## Example: compile FMS1
> ./compile_mom6.sh -b fms -n 201901

## Example: compile MOM6 ocean-only
> ./compile_mom6.sh -b mom6oo -n devgfdl -f 201901

## Example: compile MOM6SIS2
> ./compile_mom6.sh -b mom6sis2 -n devgfdl -f 201901

## Example: compile MOM6SIS2 using CEFI src
> ./compile_mom6.sh -b mom6sis2 -n cefi --fms2 --cefi_aux --cefi_mom6 -f cefi_fms

## Note
If `--eg_aux` is not used, all required code repos need to be cloned individually, including `FMS`, `coupler`, `atmos_null`, `land_null`, `ice_param`, `icebergs`.
