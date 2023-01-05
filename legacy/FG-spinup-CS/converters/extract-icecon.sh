#!/bin/bash

 source /lcrc/soft/climate/e3sm-unified/load_e3sm_unified_1.5.0_chrysalis.sh

 year1=1
 year2=500
 head=chad.240_G_case2 
 loc=/lcrc/group/e3sm/ac.sockwell/scratch/anvil/chad.240_G_case2/run/
 for year in  `seq -f "%04g" $year1 $year2`; do
     for month in `seq -w 1 12`; do
         histfile=$head.mpassi.hist.am.timeSeriesStatsMonthly.$year-$month-01.nc
         iceconfile=$head.mpassi.hist.am.IceAreaCell.$year-$month-01.nc
         echo ncks -v timeMonthly_avg_iceAreaCell $loc$histfile $loc$iceconfile
         ncks -v timeMonthly_avg_iceAreaCell $loc$histfile $loc/$iceconfile
     done
 done

