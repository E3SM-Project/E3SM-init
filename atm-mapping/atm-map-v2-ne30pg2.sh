tm_grid_file=ne30pg2.g               # see atm-topograhy
atm_scrip_grid_file=ne30pg2_scrip.nc # see atm-topograhy
ocn_grid_file=ocean.oEC60to30v3.scrip.181106.nc
lnd_grid_file=SCRIPgrid_0.5x0.5_nomask_c110308.nc

atm_name=ne30pg2
ocn_name=oEC60to30v3
lnd_name=r05

## Conservative, monotone maps.

alg_name=mono

date=200110

function run {
    echo "src $src dst $dst map $map"
    ../compsetfiles/ncremap -a tempest --src_grd=$src --dst_grd=$dst -m $map \
        -W '--in_type fv --in_np 1 --out_type fv --out_np 1 --out_format Classic --correct_areas' \
        $extra
}

extra=""

src=$ocn_grid_file
dst=$atm_grid_file
map="map_${ocn_name}_to_${atm_name}_${alg_name}.${date}.nc"
run

src=$atm_grid_file
dst=$ocn_grid_file
map="map_${atm_name}_to_${ocn_name}_${alg_name}.${date}.nc"
extra=--a2o
run
extra=""

src=$lnd_grid_file
dst=$atm_grid_file
map="map_${lnd_name}_to_${atm_name}_${alg_name}.${date}.nc"
run

src=$atm_grid_file
dst=$lnd_grid_file
map="map_${atm_name}_to_${lnd_name}_${alg_name}.${date}.nc"
run

## Nonconservative, monotone maps.

alg_name=bilin

src=$atm_scrip_grid_file
dst=$lnd_grid_file
map="map_${atm_name}_to_${lnd_name}_${alg_name}.${date}.nc"
ncremap -a bilinear -s $src -g $dst -m $map -W '--extrap_method  nearestidavg'

src=$atm_scrip_grid_file
dst=$ocn_grid_file
map="map_${atm_name}_to_${ocn_name}_${alg_name}.${date}.nc"
ncremap -a bilinear -s $src -g $dst -m $map -W '--extrap_method  nearestidavg'
