#!/bin/bash

 source /lcrc/soft/climate/e3sm-unified/load_e3sm_unified_1.5.0_chrysalis.sh

 mapfile=/lcrc/group/acme/public_html/diagnostics/mpas_analysis/maps/map_EC30to60E2r2_to_0.5x0.5degree_bilinear.nc

 year1=0001
 year2=0001
 casename=chad.240_G_case2
 for monssn in  `seq -w 1 12` DJF MAM JJA SON ANN; do
 
     timerange=${year1}${monssn}_${year2}${monssn}
     if [ $monssn == 'ANN' ]; then
        timerange=${year1}01_${year2}12
     fi
     if [ $monssn == 'DJF' ]; then
        timerange=${year1}01_${year2}12
     fi
     if [ $monssn == 'MAM' ]; then
        timerange=${year1}03_${year2}05
     fi
     if [ $monssn == 'JJA' ]; then
        timerange=${year1}06_${year2}08
     fi
     if [ $monssn == 'SON' ]; then
        timerange=${year1}09_${year2}11
     fi

     sstfile=climo/ocn/mpaso_${monssn}_${timerange}_climo.nc

     # re-arrange the order of the dimension: making nCells the fastest varying. Not needed if nVertLevels removed first

     #sstfile_rearr=climo/ocn/mpaso_${monssn}_${timerange}_climo.rearr.nc
     # echo ncpdq -a time,nVertLevels,nCells $sstfile $sstfile_rearr 
     # ncpdq -a time,nVertLevels,nCells $sstfile $sstfile_rearr 

     # remove dimension nVertLevels. If removing nVertLevels first, no need to re-arrange order of dim above
     sstfile_noLevel=climo/ocn/mpaso_${monssn}_${timerange}_climo.noLevel.nc
     echo ncwa -a nVertLevels $sstfile $sstfile_noLevel
     ncwa -a nVertLevels $sstfile $sstfile_noLevel

     sstfile_ren=climo/ocn/SST_${monssn}_${timerange}_climo.nc
     echo ncrename -v timeMonthly_avg_activeTracers_temperature,SST_cpl $sstfile_noLevel $sstfile_ren
     ncrename -v timeMonthly_avg_activeTracers_temperature,SST_cpl $sstfile_noLevel $sstfile_ren

     # regridding using 0.5x0.5_bilin map
     # dstfile=climo/0.5x0.5_bilin/ocn/${casename}.mpaso_${monssn}_${timerange}_climo.nc
     # in original order determined by the mapping file (the associated dst grid file)
     dstfile_WE=climo/0.5x0.5_bilin/ocn/${casename}_SST_${monssn}_${timerange}_climo.WE.nc

     echo ncks --map $mapfile $sstfile_ren $dstfile_WE
     ncks --map $mapfile $sstfile_ren $dstfile_WE

     # rotate the hemispheres (WE -> EW)
     dstfile_EW=climo/0.5x0.5_bilin/ocn/${casename}_SST_${monssn}_${timerange}_climo.nc
     echo ncks -O --msa -d lon,0.,180. -d lon,-180.,-0.1 $dstfile_WE $dstfile_EW
     ncks -O --msa -d lon,0.,180. -d lon,-180.,-0.1 $dstfile_WE $dstfile_EW

     # Reset the W. Hemisphere longitudes in 0-360 degree convention
     echo ncap2 -O -s 'where(lon < 0) lon=lon+360' $dstfile_EW $dstfile_EW
     ncap2 -O -s 'where(lon < 0) lon=lon+360' $dstfile_EW $dstfile_EW

     # The regridded data does not have _FillValue attribute; undefined/missing values default to 0
     # First set _FillValue attribute for variable SST_cpl with the value set to the default missing value
     ncatted -a_FillValue,SST_cpl,a,f,0.0 $dstfile_EW
     # Then modify the _FillValue to be a large value 1.0e36, to distinigush from valid value
     ncatted -a_FillValue,SST_cpl,m,f,1.0e+36 $dstfile_EW


     # Ice Area Concentration
     iceconfile=climo/ice/mpassi_${monssn}_${timerange}_climo.nc
     iceconfile_ren=climo/ice/iceArea_${monssn}_${timerange}_climo.nc
     echo ncrename -v timeMonthly_avg_iceAreaCell,ice_cov $iceconfile $iceconfile_ren
     ncrename -v timeMonthly_avg_iceAreaCell,ice_cov $iceconfile $iceconfile_ren

     dstfile_WE=climo/0.5x0.5_bilin/ice/${casename}_iceArea_${monssn}_${timerange}_climo.WE.nc
     dstfile_EW=climo/0.5x0.5_bilin/ice/${casename}_iceArea_${monssn}_${timerange}_climo.nc

     echo ncks --map $mapfile $iceconfile_ren $dstfile_WE
     ncks --map $mapfile $iceconfile_ren $dstfile_WE

     echo ncks -O --msa -d lon,0.,180. -d lon,-180.,-0.1 $dstfile_WE $dstfile_EW
     ncks -O --msa -d lon,0.,180. -d lon,-180.,-0.1 $dstfile_WE $dstfile_EW

     echo ncap2 -O -s 'where(lon < 0) lon=lon+360' $dstfile_EW $dstfile_EW
     ncap2 -O -s 'where(lon < 0) lon=lon+360' $dstfile_EW $dstfile_EW

 done

 year1=0001
 year2=0001
 casename=chad.240_G_case2
 # concatenate monthly climo into a single file
 WKDIR=`pwd`
 cd climo/0.5x0.5_bilin/ocn
 ncrcat ${casename}_SST_??_*_climo.nc -o ${casename}_SST_climo_${year1}-${year2}.nc
 # rename Time dimension to time as assumed in later step
 ncrename -d Time,time ${casename}_SST_climo_${year1}-${year2}.nc

 cd $WKDIR
 cd climo/0.5x0.5_bilin/ice
 ncrcat ${casename}_iceArea_??_*_climo.nc -o ${casename}_iceArea_climo_${year1}-${year2}.nc
 ncrename -d Time,time ${casename}_iceArea_climo_${year1}-${year2}.nc

 # add _fillvalue attribute for variable ice_cov. filling for land grids will refer to this fillvalue
 ncatted -a_FillValue,ice_cov,a,f,1.0e36 ${casename}_iceArea_climo_${year1}-${year2}.nc

 # Diddling and consistency check of SST and Sea Ice: based on a ncl script provided by Jim Benedict

 # Adjust SST and ice area concentration to ensure monthly mean of runtime temporally interpolated data 
 #        data will equal to the actual prescribed monthly data

 cd $WKDIR

 # set and pass env variable to ncl diddling program

 export INPUT_SST_FILE=climo/0.5x0.5_bilin/ocn/${casename}_SST_climo_${year1}-${year2}.nc
 export INPUT_SEAICE_FILE=climo/0.5x0.5_bilin/ice/${casename}_iceArea_climo_${year1}-${year2}.nc
 export OUTPUT_SSTICE_FILE=sst_ice_${casename}_0.5x0.5_climo_${year1}-${year2}.nc
 export caseName=$casename

 # Set path to NCL, may do 
 # 1. "module load ncl" if available as module
 # 2. "conda activate ncl_stable"   if installed in a conda environment
 # 3.  export NCARG_ROOT=/soft/bebop/ncl/6.6.2  tell where to find ncl if installed in regular shell env

 conda activate ncl_stable

 ncl < sst_ice_climo_diddle.ncl | tee log.diddling_consistency

 conda deactivate

 source /lcrc/soft/climate/e3sm-unified/load_e3sm_unified_1.5.0_chrysalis.sh

 cdate=`date +%y%m%d`
 domainOcnFile=domain.ocn.0.5x0.5.c$cdate.nc
 ncks -M -v lat,lon sst_ice_${casename}_0.5x0.5_climo_${year1}-${year2}.nc $domainOcnFile
 ncrename -v lat,yc -v lon,xc $domainOcnFile

 exit
