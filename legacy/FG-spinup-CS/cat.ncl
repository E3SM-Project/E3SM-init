; ***********************************************
; glc2scripConvert.ncl
; ***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************************
begin

dir    = "/lcrc/group/e3sm/ac.sockwell/scratch/anvil/chad.240_F_case_iter/run/"
prefix = "chad.240_F_case_iter"
year_begin = 0
year_end   = 1

types = (/"ha2x1d", "ha2x1h", "ha2x1hi", "ha2x3h"/)

do year=year_begin,year_end
  do month=1,12
    do type=0,3
      files_in = dir+prefix+".cpl."+types(type)+"."+sprinti("%0.4i", year)+"-"+sprinti("%0.2i", month)+"-*"
      file_out = dir+prefix+".cpl."+types(type)+"."+sprinti("%0.4i", year)+"-"+sprinti("%0.2i", month)+".nc"

      ncocmd= "ncrcat "+files_in+" "+file_out
      print ("ncocmd = "+ncocmd)
      system (ncocmd)

      rmcmd = "/bin/rm -f "+files_in
      print ("rmcmd ="+ rmcmd)
      system (rmcmd)

    end do
  end do
end do

end
