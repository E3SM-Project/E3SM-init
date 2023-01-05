#!/bin/bash

 source /lcrc/soft/climate/e3sm-unified/load_e3sm_unified_1.5.0_chrysalis.sh

 year1=1
 year2=1

 head=chad.240_G_case2 
 loc=/lcrc/group/e3sm/ac.sockwell/scratch/anvil/chad.240_G_case2/run/
 cd $loc
 for year in  `seq -f "%04g" $year1 $year2`; do
     for month in `seq -w 1 12`; do
         iceconfile=$head.mpassi.hist.am.IceAreaCell.$year-$month-01.nc
         newfile=$head.mpassi.hist.am.timeSeriesStatsMonthly.$year-$month-01.nc
         echo mv $iceconfile $newfile
         mv $iceconfile $newfile
     done
 done

