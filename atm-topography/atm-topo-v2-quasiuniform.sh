E3SM=~/e3sm
HOMME=~/standalone

ne=30
cubedsphere=ne${ne}

## Dependencies:
# E3SM inputdata directory
inputdata=/compyfs/inputdata
# Dependency 1. Location of TempestRemap binaries
tempest_root=~zender/bin
# Dependency 2. Location of cube_to_target executable
cube_to_target=${E3SM}/components/eam/tools/topo_tool/cube_to_target
# Dependency 3. Location of homme_tool executable
homme_tool=${HOMME}/src/tool/homme_tool

# 1. Use TempestRemap to create ne30pg4,2 grids:

${tempest_root}/GenerateCSMesh --alt --res 256 --file ${cubedsphere}.g
${tempest_root}/GenerateVolumetricMesh --in ${cubedsphere}.g --out ${cubedsphere}pg2.g --np 2 --uniform
${tempest_root}/GenerateVolumetricMesh --in ${cubedsphere}.g --out ${cubedsphere}pg4.g --np 4 --uniform
${tempest_root}/ConvertExodusToSCRIP --in ${cubedsphere}pg4.g --out ${cubedsphere}pg4_scrip.nc
${tempest_root}/ConvertExodusToSCRIP --in ${cubedsphere}pg2.g --out ${cubedsphere}pg2_scrip.nc

# 2. Use cube_to_target to get unsmoothed topo data on ne30pg4:

${cube_to_target} --target-grid ${cubedsphere}pg4_scrip.nc --input-topography ${inputdata}/atm/cam/topo/USGS-topo-cube3000.nc --output-topography ${cubedsphere}pg4_c2t_topo.nc

# 3. Use homme_tool to map to ne30np4, smooth to create ne30pg2 PHIS_d, then map
#    to ne30pg2 to create PHIS:

cat <<EOF >> input.nl
&ctl_nl
ne = ${ne}
smooth_phis_numcycle = 16
smooth_phis_nudt = 28e7
hypervis_scaling = 0 
hypervis_order = 2
se_ftype = 2 ! actually output NPHYS; overloaded use of ftype
/
&vert_nl
/
&analysis_nl
tool = 'topo_pgn_to_smoothed'
infilenames = 'ne30pg4_c2t_topo.nc', 'ne30np4pg2_smoothed_phis'
/
EOF

export OMP_NUM_THREADS=1
mpirun -np 8 ${homme_tool} < input.nl

# 4. Use cube_to_target to compute SGH, SGH30, LANDFRAC, LANDM_COSLAT for
#    ne30pg2 PHIS:

${cube_to_target} --target-grid ${cubedsphere}pg2_scrip.nc --input-topography ${inputdata}/atm/cam/topo/USGS-topo-cube3000.nc --smoothed-topography ${cubedsphere}np4pg2_smoothed_phis1.nc --output-topography USGS-gtopo30_${cubedsphere}np4pg2_16xdel2.nc

# 5. Use ncks to put ne30pg2 data and ne30np4 PHIS_d into one file:

ncks -A ${cubedsphere}np4pg2_smoothed_phis1.nc USGS-gtopo30_${cubedsphere}np4pg2_16xdel2.nc

# USGS-gtopo30_ne30np4pg2_16xdel2.nc is the final GLL-physgrid topography file.
