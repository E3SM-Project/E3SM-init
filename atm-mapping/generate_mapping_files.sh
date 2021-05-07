#!/bin/bash

# NOTES
# This is setup for a RRM trigrid, with hard-coded ocean and land grid names
# and files. You will want to modify these for your uses. config.sh should set
# the variables referenced here (atm_grid_name, inputdata_root, etc.).

# Set paths
source config.sh
atm_grid_file=${output_root}/${atm_grid_name}pg2.g
ocn_grid_file=${inputdata_root}/ocn/mpas-o/oARRM60to10/ocean.ARRM60to10.scrip.200413.nc
lnd_grid_file=${inputdata_root}/lnd/clm2/mappingdata/grids/MOSART_global_8th.scrip.20180211c.nc #${atm_grid_file}

declare -A grid_files
grid_files["${atm_grid_name}"]=${atm_grid_file}
grid_files["${lnd_grid_name}"]=${lnd_grid_file}
for grid in ${atm_grid_name} ${lnd_grid_name}; do
    echo ${grid} ${grid_files[$grid]}
done

# Set date for output file names
date=`date +'%Y%m%d'`

for grid_name in ${atm_grid_name} ${lnd_grid_name}; do
    # Set grid file for this grid name
    grid_file=${grid_files[${grid_name}]}
    # Generate overlap mesh
    echo "Generate overlap mesh..."
    overlap_mesh=${output_root}/overlap_${ocn_grid_name}_to_${grid_name}.nc
    if [ ! -e ${overlap_mesh} ]; then
        GenerateOverlapMesh --a ${ocn_grid_file} --b ${grid_file} --out ${overlap_mesh}
    fi
    # Generate maps
    echo "Generate atm -> ocn map.."
    map_file=${output_root}/map_${grid_name}_to_${ocn_grid_name}_mono.${date}.nc
    if [ ! -e ${map_file} ]; then
    GenerateOfflineMap \
        --in_mesh ${grid_file} --out_mesh ${ocn_grid_file} --ov_mesh ${overlap_mesh} \
        --in_type fv --in_np 1 --out_type fv --out_np 1 --correct_areas \
        --out_map ${map_file}
    fi
    echo "Generate ocn -> atm map.."
    map_file=${output_root}/map_${ocn_grid_name}_to_${grid_name}_mono.${date}.nc
    if [ ! -e ${map_file} ]; then
        GenerateOfflineMap \
            --in_mesh ${ocn_grid_file} --out_mesh ${grid_file} --ov_mesh ${overlap_mesh} \
            --in_type fv --in_np 1 --out_type fv --out_np 1 --correct_areas \
            --out_map ${map_file}
    fi
done

# Generate NCO maps
map_file=${output_root}/map_${lnd_grid_name}_to_${ocn_grid_name}_nco${date}.nc
ncremap --src_grd=${lnd_grid_file} --dst_grd=${ocn_grid_file} -m ${map_file}
map_file=${output_root}/map_${ocn_grid_name}_to_${lnd_grid_name}_nco${date}.nc
ncremap --src_grd=${ocn_grid_file} --dst_grd=${lnd_grid_file} -m ${map_file}
