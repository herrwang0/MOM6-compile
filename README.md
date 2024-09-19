# MOM6-compile

Quick compile for MOM6

All codes are assumed to stored in `$USER/src`. All builds are placed in `build`.

## Options
* -b: Build. can be `fms`, `mom6oo` or `mom6sis2`
* -n: Name. Name for the build
* -e: Use code from MOM6-examples
* -t: Target. Either `repro` or `debug`
* -f: FMS library build name. Required for ocean-only or SIS2 coupled MOM6

## Example: compile FMS1
> ./compile_mom6.sh -b fms -n 201901

## Example: compile MOM6 ocean-only
> ./compile_mom6.sh -b mom6oo -n devgfdl -f 201901

## Example: compile MOM6SIS2
> ./compile_mom6.sh -b mom6sis2 -n devgfdl -f 201901

## Note
If `-e` is not used, all required code repos need to be cloned individually, including `FMS`, `MOM6`, `mkmf`, coupler, icebergs etc ...