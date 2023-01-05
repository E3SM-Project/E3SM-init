# activate e3sm_unified
source /lcrc/soft/climate/e3sm-unified/load_e3sm_unified_1.5.0_chrysalis.sh
# Extract monthly SST data, reset the path for history file and extracted sst as needed
 caseid=chad.240_G_case2
 year1=0001
 year2=0001
 loc=/lcrc/group/e3sm/ac.sockwell/scratch/anvil/chad.240_G_case2/run/

 for year in  `seq -f "%04g" $year1 $year2`; do
     for month in `seq -w 1 12`; do
         histfile=$loc/$caseid.mpaso.hist.am.timeSeriesStatsMonthly.$year-$month-01.nc
         sstfile=SSTDATA/mpaso.hist.am.timeSeriesStatsMonthly.$year-$month-01.nc
         ncks -v timeMonthly_avg_activeTracers_temperature -d nVertLevels,0,0 $histfile $sstfile
     done
 done
 
# Extract sea ice area coverage, reset the path as needed
 for year in  `seq -f "%04g" $year1 $year2`; do
     for month in `seq -w 1 12`; do
         histfile=$loc/$caseid.mpassi.hist.am.timeSeriesStatsMonthly.$year-$month-01.nc
         icecovfile=IceAreaData/mpassi.hist.am.timeSeriesStatsMonthly.$year-$month-01.nc
         ncks -v timeMonthly_avg_iceAreaCell $histfile $icecovfile
     done
 done
 
# compute climo, assuming climo/ocn and climo/ice exist
 ncclimo -m mpaso -s $year1 -e $year2 -i SSTDATA -o climo/ocn
 ncclimo -m mpassi -s $year1 -e $year2 -i IceAreaData -o climo/ice
 
# regrid the climo files and rename the SST and ice coverage variables
# reset the path for regridded data as needed. here use climo/0.5x0.5_bilin/ocn and ice
 mapfile=map_oQU240_to_90x180_nco.20201001.nc
 for mon in  `seq -w 1 12`; do
     timerange=${year1}${mon}_${year2}${mon}
     sstfile=climo/ocn/mpaso_${mon}_${timerange}_climo.nc
     # remove dimension nVertLevels, by averaging over the dimension of size 1
     sstfile_noLevel=climo/ocn/mpaso_${monssn}_${timerange}_climo.noLevel.nc
     ncwa -a nVertLevels $sstfile $sstfile_noLevel
     # rename the SST variable
     sstfile_ren=climo/ocn/SST_${mon}_${timerange}_climo.nc
     ncrename -v timeMonthly_avg_activeTracers_temperature,SST_cpl $sstfile_noLevel $sstfile_ren
     
     # regridding using 0.5x0.5_bilin map
     # in original orientation determined by the mapping file (the associated dst grid file)
     dstfile_EW=climo/0.5x0.5_bilin/ocn/${caseid}_SST${monssn}_${timerange}_climo.nc
      ncks --map $mapfile $sstfile_ren $dstfile_EW

     # rotate the hemispheres (WE -> EW)
#     dstfile_EW=climo/0.5x0.5_bilin/ocn/${caseid}_SST_${monssn}_${timerange}_climo.nc
#     echo ncks -O --msa -d lon,0.,180. -d lon,-180.,-0.1 $dstfile_WE $dstfile_EW
#     ncks -O --msa -d lon,0.,180. -d lon,-180.,-0.1 $dstfile_WE $dstfile_EW

     # Reset the W. Hemisphere longitudes in 0-360 degree convention
   #  echo ncap2 -O -s 'where(lon < 0) lon=lon+360' $dstfile_EW $dstfile_EW
   #  ncap2 -O -s 'where(lon < 0) lon=lon+360' $dstfile_EW $dstfile_EW

     # The regridded data does not have _FillValue attribute; undefined/missing values default to 0
     # First set _FillValue attribute for variable SST_cpl with the value set to the default missing value
     ncatted -a_FillValue,SST_cpl,a,f,0.0 $dstfile_EW
     # Then modify the _FillValue to be a large value 1.0e36, to distinigush from valid value
     ncatted -a_FillValue,SST_cpl,m,f,1.0e+36 $dstfile_EW
     
     # Ice Area Concentration, rename, regrid, and rotate the hemisphere
     icecovfile=climo/ice/mpassi_${mon}_${timerange}_climo.nc
     icecovfile_ren=climo/ice/iceArea_${mon}_${timerange}_climo.nc
     echo ncrename -v timeMonthly_avg_iceAreaCell,ice_cov $icecovfile $icecovfile_ren
     ncrename -v timeMonthly_avg_iceAreaCell,ice_cov $icecovfile $icecovfile_ren

   #  dstfile_WE=climo/0.5x0.5_bilin/ice/${caseid}_iceArea${monssn}_${timerange}_climo.WE.nc
     dstfile_EW=climo/0.5x0.5_bilin/ice/${caseid}_iceArea${monssn}_${timerange}_climo.nc

     ncks --map $mapfile $icecovfile_ren $dstfile_EW
  #   ncks -O --msa -d lon,0.,180. -d lon,-180.,-0.1 $dstfile_WE $dstfile_EW
  #   ncap2 -O -s 'where(lon < 0) lon=lon+360' $dstfile_EW $dstfile_EW
done
 # concatenate monthly climo into a single file
 WKDIR=`pwd`
 cd climo/0.5x0.5_bilin/ocn
 ncrcat ${caseid}_SST_*_climo.nc -o ${caseid}_SST_climo_${year1}-${year2}.nc
 # rename Time dimension to time as assumed in later step
 ncrename -d Time,time ${caseid}_SST_climo_${year1}-${year2}.nc

 cd $WKDIR
 cd climo/0.5x0.5_bilin/ice
 ncrcat ${caseid}_iceArea_*_climo.nc -o ${caseid}_iceArea_climo_${year1}-${year2}.nc
 ncrename -d Time,time ${caseid}_iceArea_climo_${year1}-${year2}.nc

 # add _fillvalue attribute for variable ice_cov. filling for land grids will refer to this fillvalue
 ncatted -a_FillValue,ice_cov,a,f,1.0e36 ${caseid}_iceArea_climo_${year1}-${year2}.nc

 # Diddling and consistency check of SST and Sea Ice: based on a ncl script provided by Jim Benedict

 # Adjust SST and ice area concentration to ensure monthly mean of runtime temporally interpolated data
 #        data will equal to the actual prescribed monthly data

 cd $WKDIR

 # set and pass env variable to ncl diddling program

 export INPUT_SST_FILE=climo/0.5x0.5_bilin/ocn/${caseid}_SST_climo_${year1}-${year2}.nc
 export INPUT_SEAICE_FILE=climo/0.5x0.5_bilin/ice/${caseid}_iceArea_climo_${year1}-${year2}.nc
 export OUTPUT_SSTICE_FILE=sst_ice_${caseid}_0.5x0.5_climo_${year1}-${year2}.nc
 export caseName=$caseid

 # Set path to NCL, may do
 # 1. "module load ncl" if available as module
 # 2. "conda activate ncl_stable"   if installed in a conda environment
 # 3.  export NCARG_ROOT=/soft/bebop/ncl/6.6.2  tell where to find ncl if installed in regular shell env

 #conda activate ncl_stable

 ncl < sst_ice_climo_diddle.ncl | tee log.diddling_consistency

 #conda deactivate
 # reactivate e3sm_unified
  source /lcrc/soft/climate/e3sm-unified/load_e3sm_unified_1.5.0_chrysalis.sh
 #
 # derive domain file from the generated SSTICE data 
  cdate=`date +%y%m%d`
  domainOcnFile=domain.ocn.0.5x0.5.c$cdate.nc
  ncks -M -v lat,lon sst_ice_${caseid}_0.5x0.5_climo_${year1}-${year2}.nc $domainOcnFile
  ncrename -v lat,yc -v lon,xc $domainOcnFile
