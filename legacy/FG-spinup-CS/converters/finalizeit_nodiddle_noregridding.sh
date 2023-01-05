#!/bin/bash

 source /lcrc/soft/climate/e3sm-unified/load_e3sm_unified_1.5.0_chrysalis.sh
 
 # if monthly climo prepared separately. use this as a finishing step

 year1=0001
 year2=0001

 casename=chad.240_G_case2 
 # concatenate monthly climo into a single file
 WKDIR=`pwd`
 cd climo/ocn
 ncrcat mpaso_*_climo.nc -o ${casename}_SST_climo_${year1}-${year2}.nc
 # rename Time dimension to time as assumed in later step
 #ncrename -d Time,time ${casename}_SST_climo_${year1}-${year2}.nc

 cd $WKDIR
 cd climo/ice
 ncrcat mpassi_*_climo.nc -o ${casename}_iceArea_climo_${year1}-${year2}.nc
 #ncrename -d Time,time ${casename}_iceArea_climo_${year1}-${year2}.nc

 # Ice Area Concentration
 #iceconfile=climo/ice/mpassi_${monssn}_${timerange}_climo.nc
 #iceconfile_ren=climo/ice/iceArea_${monssn}_${timerange}_climo.nc
 #echo ncrename -v timeMonthly_avg_iceAreaCell,ice_cov $iceconfile $iceconfile_ren
 #ncrename -v timeMonthly_avg_iceAreaCell,ice_cov $iceconfile $iceconfile_ren

 # add _fillvalue attribute for variable ice_cov. filling for land grids will refer to this fillvalue
 ncatted -a_FillValue,ice_cov,a,f,1.0e36 ${casename}_iceArea_climo_${year1}-${year2}.nc

 # Diddling and consistency check of SST and Sea Ice: based on a ncl script provided by Jim Benedict

 # Adjust SST and ice area concentration to ensure monthly mean of runtime temporally interpolated data 
 #        data will equal to the actual prescribed monthly data

 cd $WKDIR

 # set and pass env variable to ncl diddling program

 export INPUT_SST_FILE=climo/ocn/${casename}_SST_climo_${year1}-${year2}.nc
 export INPUT_SEAICE_FILE=climo/ice/${casename}_iceArea_climo_${year1}-${year2}.nc
 export OUTPUT_SSTICE_FILE=sst_ice_${casename}_climo_${year1}-${year2}.no_diddling.nc
 export caseName=$casename

 # Set path to NCL, may  simply do "module load ncl" if available
 # Below to set it for chrysalis
 # export NCARG_ROOT=/soft/bebop/ncl/6.6.2
 #conda activate ncl_stable
 module load ncl

 ncl < sst_ice_climo_diddle.ncl | tee log.diddling_consistency

 conda deactivate

 exit

# source /lcrc/soft/climate/e3sm-unified/load_e3sm_unified_1.5.0_chrysalis.sh
  
# cdate=`date +%y%m%d`
# domainOcnFile=domain.ocn.0.5x0.5.c$cdate.nc
# ncks -M -v lat,lon sst_ice_${casename}_0.5x0.5_climo_${year1}-${year2}.nc $domainOcnFile
# ncrename -v lat,yc -v lon,xc $domainOcnFile


# exit
