#!/bin/bash
# See:
# https://acme-climate.atlassian.net/wiki/spaces/ED/pages/1043235115/Special+Considerations+for+FV+Physics+Grids
#
# Variables that need to be set:
#
#     output_root:  location where you want to save generated files
#     tempest_root: path to TempestRemap build
#     atm_grid_name: name of atmosphere grid (ne1024pg2, myrrmmeshx4v1, etc)
#     atm_grid_res: resolution of grid (30, 1024, etc)
#
# I usually save these in a config file, and source as follows:
#     source config.sh

# Generate element quadrilaterals
# NOTE: if you are generating an RRM grid, you should already have a mesh file
# created using SQuadGen, and you will SKIP THIS STEP!
${tempest_root}/bin/GenerateCSMesh --alt --res ${atm_grid_res} --file ${atm_grid_name}.g

# Generate pg2 mesh from element quadrilaterals
${tempest_root}/bin/GenerateVolumetricMesh \
    --in ${output_root}/${atm_grid_name}.g \
    --out ${output_root}/${atm_grid_name}pg2.g \
    --np 2 --uniform
# Create a SCRIP-format file describing the pg2 mesh
${tempest_root}/bin/ConvertExodusToSCRIP --in ${output_root}/${atm_grid_name}pg2.g --out ${output_root}/${atm_grid_name}pg2_scrip.nc
