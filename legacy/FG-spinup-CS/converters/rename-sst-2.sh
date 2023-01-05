#!/bin/bash

 source /lcrc/soft/climate/e3sm-unified/load_e3sm_unified_1.5.0_chrysalis.sh

 year1=1
 year2=1

 head=chad.240_G_case2 
 loc=/lcrc/group/e3sm/ac.sockwell/scratch/anvil/chad.240_G_case2/run
 cd $loc
 for year in  `seq -f "%04g" $year1 $year2`; do
     for month in `seq -w 1 12`; do
         srcfile=$head.mpaso.hist.am.timeSeriesStatsMonthly.$year-$month-01.nc
         dstfile=mpaso.hist.am.timeSeriesStatsMonthly.$year-$month-01.nc
         echo mv $srcfile $dstfile
         mv $srcfile $dstfile
     done
 done


 # since extracted sst data has vertical dimension varying fastest, need to adjust to have horizontal the 1st dimension before applying remapping
 # ncpdq -a time,nVertLevels,nCells sst.nc sst-n.nc
 # regridding use: ncks --map /lcrc/group/acme/public_html/diagnostics/mpas_analysis/maps/map_EC30to60E2r2_to_0.5x0.5degree_bilinear.nc sst-n.nc rgr-sst.nc
 # regridded data starting from east of date line. need to be rearranged

 # generating climo using following format. It would analyze "timeSeriesStatsMonthly" analysis 

 # ncclimo -m mpaso      -s 1980 -e 1983 -i drc_in -o drc_out # MPAS-O
 # cclimo -m mpassi -s 1980 -e 1983 -i drc_in -o drc_out # MPAS-I
