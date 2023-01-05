#!/bin/bash

 source /lcrc/soft/climate/e3sm-unified/load_e3sm_unified_1.5.0_chrysalis.sh

 cd /lcrc/group/e3sm/ac.sockwell/scratch/anvil/chad.240_G_case2/run/
 loc=/lcrc/group/e3sm/ac.sockwell/scratch/anvil/chad.240_G_case2/run
 head=chad.240_G_case2 
 year1=1
 year2=1

 nice ncclimo -m mpaso -s $year1 -e $year2 -i $loc -o ~/converters/climo/ocn # MPAS-O
 nice ncclimo -m mpassi -s $year1 -e $year2 -i $loc -o ~/converters/climo/ice # MPAS-I
