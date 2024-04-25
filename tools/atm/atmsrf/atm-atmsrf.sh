physics_grid=ne30pg2
date=200129

# 1. Build the mkatmsrffile tool.
cd ${E3SM}/components/cam/tools/mkatmsrffile/
make

# 2. Make a map file:
ncremap -a tempest \
  --src_grd=1x1d.nc --dst_grd=${physics_grid}.g \
  -m map_1x1_to_${physics_grid}_mono.nc \
  -W '--in_type fv --in_np 1 --out_type fv --out_np 1 --out_format Classic'

# 3. Gather these files:
# /project/projectdirs/acme/mapping/grids/1x1d.nc
# /project/projectdirs/acme/inputdata/atm/cam/chem/trop_mozart/dvel/regrid_vegetation.nc
# /project/projectdirs/acme/inputdata/atm/cam/chem/trop_mozart/dvel/clim_soilw.nc

# 4. Make a namelist like this:
cat <<EOF >> nml_atmsrf
&input
srfFileName = '1x1d.nc'
landFileName = 'regrid_vegetation.nc'
soilwFileName = 'clim_soilw.nc'
# See the TempestRemap section of atm-topo-v2-quasiuniform.sh to generated this file:
atmFileName = '${physics_grid}_scrip.nc'
srf2atmFmapname = 'map_1x1_to_${physics_grid}_mono.nc'
outputFileName = 'atmsrf_${physics_grid}_${date}_n4.nc'
/
EOF

# 5. Run the tool in the same directory as nml_atmsrf resides.
./mkatmsrffile

# 6. Finally, convert the file to netcdf3 format:
ncks -3 atmsrf_${physics_grid}_${date}_n4.nc atmsrf_${physics_grid}_${date}.nc
