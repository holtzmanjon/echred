# By Pey Lian Lim (5/17/05)
#
# Needs list of normalized spectra.
# Only headers added, spectra not modified.
#
# Get a list of observed velocities from XCSAO.
# Read that list and compute VOBS and DELVOB. Those with R<10 excluded.
# Use RVCORRECT to get VHELIO.
#
# To be called from echred.cl
#   task getvel = getvel.cl
#   getvel(inputlist=listname)

procedure getvel (inputlist)

char inputlist {prompt = 'Input list'}
string *list
struct *list2

begin
  char s1, inlist, path, tpath, imgspc, imgtmp, logfil, dummy
  int nsum
  real vobs, dvobs, rval, vsum, v2sum, varsum, rsum, rlimit

  inlist = inputlist
  path = "./"
  tpath = "/home/holtz/analysis/hipparcos/ref/"
  list = inlist
  imgtmp = "solarflux.fits,arcturus.fits"
  rlimit = 10.0

# Open  the IRAF task packages to be used in this script
  astutil
  rvsao

# Loops through object list
  while(fscan(list,s1)!=EOF) {
    imgspc = path//s1
    imdel norm.fits
    imarith(operand1=imgspc//".mash.ec.fits",op="/",operand2=imgspc//".cont.ec.fits",result="norm.fits")

#    imgspc = path//s1//".norm.ec.fits"
    logfil = path//s1//".xcsao.log"

    del path//s1//".xcsao.log"

# Get observed velocities from XCSAO
    xcsao(spectra="norm.fits",specnum="30-60",specband=1,specdir="",correla="velocity",template=imgtmp,tempnum=0,tempband=1,tempdir=tpath,echelle=no,st_lamb=INDEF,end_lam=INDEF,limfile="",obj_plo=no,xcor_pl=no,xcor_fi=no,fixbad=no,s_emcho=no,t_emcho=no,renorma=no,ncols=2048,interp_="spline3",zeropad=no,vel_ini="correlation",czguess=0.,nzpass=0,tshift=0.,svel_co="none",tvel_co="none",pkmode=1,pkfrac=0.5,report_=4,logfile=logfil,save_ve=no,rvcheck=no,archive=no,nsmooth=0,displot=no,nsum=1)

    flpr
    flpr

# Calculate VOBS from XCSAO log
    vsum = 0.0
    v2sum = 0.0
    varsum = 0.0
    rsum = 0.0
    nsum = 0
    list2 = logfil
    while(fscan(list2,dummy,dummy,rval,vobs,dvobs) != EOF) {
      if (rval>=rlimit) {
#	vsum = vsum + (rval*vobs)
#	rsum = rsum + rval
#	varsum = varsum + (dvobs*dvobs)*(rval*rval)

	vsum = vsum + vobs
	v2sum = v2sum + (vobs*vobs)
        nsum = nsum + 1
	rsum = rsum + 1/(dvobs*dvobs)
      }
    }
#    vobs = vsum/rsum
#    dvobs = sqrt(varsum)/rsum
    if (nsum>0) {
      vobs = vsum / nsum
      dvobs = sqrt(v2sum - (vsum*vsum)/nsum)
    }

# Put calculated VOBS and DELVOB in image header
    hedit(images=imgspc//".mash.ec.fits",fields="VOBS",value=vobs,add=yes,addonly=yes,delete=no,verify=no,show=yes,update=yes)
    hedit(images=imgspc//".fits",fields="VOBS",value=vobs,add=yes,addonly=yes,delete=no,verify=no,show=yes,update=yes)
    hedit(images=imgspc//".mash.ec.fits",fields="DELVOB",value=dvobs,add=yes,addonly=yes,delete=no,verify=no,show=yes,update=yes)
    hedit(images=imgspc//".fits",fields="DELVOB",value=dvobs,add=yes,addonly=yes,delete=no,verify=no,show=yes,update=yes)

# Calculate VHELIO and save to image header
# Header keywords defined in KEYWPARS
    rvcorrect(files="",images=imgspc//".mash.ec.fits",header=yes,input=yes,imupdat=yes,epoch=INDEF,observa="apo",vsun=20.,ra_vsun=18.,dec_vsu=30.,epoch_v=1900.,year=INDEF,month=INDEF,day=INDEF,ut=INDEF,ra=INDEF,dec=INDEF,vobs=INDEF)
    rvcorrect(files="",images=imgspc//".fits",header=yes,input=yes,imupdat=yes,epoch=INDEF,observa="apo",vsun=20.,ra_vsun=18.,dec_vsu=30.,epoch_v=1900.,year=INDEF,month=INDEF,day=INDEF,ut=INDEF,ra=INDEF,dec=INDEF,vobs=INDEF)
    flpr
    flpr
  }
end
