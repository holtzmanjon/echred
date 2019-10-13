int idx
char root
imdel cont*.ec.fits 
imdel mash*.ec.fits 
imdel fullcont*.ec.fits 
imdel sig*.ec.fits

# APPLY MODEL APERTURES TO OBJECTS
#
# To properly account for and deal with the spatial aliasing of ARCES spectra,
# the spectra must be resampled in the order direction.  Enter the packages
# images and imgeom packages to do this with the task magnify
#
# Magnify objects by 4 in the cross-dispersion direction.
# Then apply model apertures, recenter, resize, and trace.
# Manual interactive scattered light subtraction because interactive apscat
#   in automated script doesn't work. If doing automatic apscat, turn off
#   interaction and check apscat1 and apscat2 for params.
# Then recenter and resize apertures again for better fit.
# Then extract the spectra (for 1D flatfielding). Background subtraction
#   disabled because object is bright and exp time is short.

del all.list
cp targets all.list
list = "all.list"
while (fscan (list,s1) !=EOF) {
  # save original image and clean up previous extracted version
#  s2="orig"//s1
#  imdel(s2,verify-)
#  imcopy (s1, s2)

  idx  = stridx(".",s1) - 1
  root = substr(s1,1,idx)
  s2 = "*"//root//".ec.fits"
  imdel(s2,verify-)

  print "Resampling the object by a factor of 4 in the y direction..."
  magnify (input=s1,output=s1,xmag=1,ymag=4)
  hedit (images=s1,fields="CCDSEC",value="[200:1850,1:8189]",add=no,addonly=no,delete=no,verify=no,show=yes,update=yes)

  print "Applying model apertures to the object..."
#  apall (input=s1,ref="040110.0024",format="echelle",interac=no,find=no,recenter=yes,resize=yes,edit=no,trace=yes,fittrace=yes,extract=no,extras=no,shift=no,width=18,radius=18,ylevel=0.05)
  apall (input=s1,ref="flat_fid",format="echelle",interac=no,find=no,recenter=yes,resize=yes,edit=no,trace=yes,fittrace=yes,extract=no,extras=no,shift=no,width=18,radius=18,ylevel=0.05,background="median",b_sample="-20:-15,15:20")
  
  print "Removing scattered inter-order light from the spectrum..."
  s2="noscat"//s1
  imdel(s2,verify-)
  imcopy (s1, s2)
  imdel(s1,verify-)
  #print "Time for manual apscat; Rename result *.fits to *.fit..."
  #askit
  # CHECK apscat params:
  # apscat1: spline3, 25, 10, 0.5, 5, 0
  # apscat2: spline3, 6, 3, 0.5, 5, 0
  apscatter (input=s2,output=s1,ref=s1,interac=no,find=no,recent=no,resize=no,edit=no,trace=no,fittrace=no,subtrac=yes,smooth=yes,fitscat=yes,fitsmoo=yes,nsum=-10)
  # comment next line and uncomment following to save scat/noscat images
  imdel(s2,verify-)
  #s2="scat"//s1
  #imcopy(s1,s2)

  # CWC edit
  flpr
  flpr 
  flpr
  # END CWC edit

  print "Fine-tuning apertures and extracting spectra..."
  # CWC-edit changed extras to "yes", changed weights to "variance", forced GAIN AND RDNOISE from header cards
#  apall (input=s1,ref="",format="echelle",interac=no,find=no,recenter=yes,resize=yes,edit=no,trace=no,fittrace=no,extract=yes,extras=yes,review=no,shift=no,width=18,radius=18,ylevel=0.05,background="none",weights="variance",readnoise="RDNOISE", gain="GAIN")
  # added llimit=-10, ulimit=10, background (had to edit refap!) Holtz 12/02/10
  apall (input=s1,ref="",format="echelle",interac=no,find=no,recenter=yes,resize=yes,edit=no,trace=no,fittrace=no,extract=yes,extras=yes,review=no,shift=no,width=18,radius=18,ylevel=0.05,llimit=-10,ulimit=10,background="median",skybox=10,weights="variance",readnoise="RDNOISE", gain="GAIN")
  # original extraction (note: weights is set in upar parameter file)
  #apall (input=s1,ref="",format="echelle",interac=no,find=no,recenter=yes,resize=yes,edit=no,trace=no,fittrace=no,extract=yes,extras=no,review=no,shift=no,width=18,radius=18,ylevel=0.05,background="none")

  imdel(s1,verify-)
#  s2="orig"//s1
#  imcopy (s2, s1)
#  imdel(s2,verify-)

# end while 
}  

# DIVIDE OBJECT SPECTRA AND WAVECALS BY THE SUPERFLAT (1D FLATFIELDING)
#
# Divide by the normalized, extracted fiducial flat prior to dispersion 
# correcting object images.  The reasoning is as follows:
#
#	"Flatfielding should be done prior to dispersion correction, i.e.
#	strictly in pixel space. Dispcor resamples the spectra when it 
#	linearizes the dispersion and thus loses some FPN information." 
#	(J. Thorburn)
#
# Added the provision for flat-fielding the wavecals in hopes of recovering 
# response particularly in the blue, leading to the ID'ing of more lines.
#
# PL: 2D flatfielding is bad in our case due to narrow apertures.
#     So we use this 1D flatfielding, assuming response is same in the
#     cross-dispersion direction.

print "Flatfielding extracted arcs and object spectra..."
del targets_extracted 
hsel *.ec.fits $I 'IMAGETYP == "object"' > targets_extracted
del all.list
cp targets_extracted all.list
list = "all.list"
setjd (images="@all.list",jd="jd",hjd="",ljd="")
while (fscan(list,s1) !=EOF) {
  print imarith: (s1)

#  imcopy (input=s1,output="noflat"//s1)
#  imarith(operand1=s1,op="/",operand2="nonorm_flat_fid.ec.fits",result=s1)
#  imcopy (input=s1,output="flat"//s1)

  imarith(operand1=s1,op="/",operand2="flat_fid.ec.fits",result=s1)
  onedspec
  print refspectra (s1)
  refspectra (input=s1,references="@arcs_extracted",answer=yes,sort="JD",group="",time=yes,confirm=no,overrid=yes,assign=yes,select="nearest")
  print dispcor (s1)
  dispcor (input=s1,output=s1,flux=no,linearize=no,log-,verbose=yes)

# Extract mash image and clip bad pixels
  s2="mash"//s1
  imdel(s2,verify-)
  imcopy (input=s1//"[*,*,2]",output=s2)
  imreplace (s2,upper=0,value=0)
  imreplace (s2,lower=1000000,value=0)
  imdel mask.ec.fits
  imarith(operand1=s2,op="/",operand2=s2,result="mask.ec.fits")

# get continuum and save as cont image
  s2="cont"//s1
  imdel(s2,verify-)
  getcont(input=s1)
  imcopy (input="fullcont"//s1//"[*,*,1]",output=s2)

# extract sig image and apply mask
  s2="sig"//s1
  imdel(s2,verify-)
  # modified to 4 from 3 when adding background subtraction
  imcopy (input=s1//"[*,*,4]",output=s2)
  imarith(operand1=s2,op="*",operand2="mask.ec.fits",result=s2)
  #imdel(s1,verify-)
  imdel("fullcont"//s1,verify-)
}

#refspectra (input="nonorm_flat_fid.ec.fits",references="@arcs_extracted",answer=yes,sort="UTMIDDLE",group="",time=yes,confirm=no,overrid=yes,assign=yes)
#dispcor (input="nonorm_flat_fid.ec.fits",output="nonorm_flat_fid.ec.fits",flux=no,linearize=no,log-,verbose=yes)
