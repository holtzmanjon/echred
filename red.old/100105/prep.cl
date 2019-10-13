# MAKE IMAGE LISTS OF FLATS 
#
# Generate a list of flat field frames sorted by whether the flat was made 
# through the blue filter.  Observers are advised to take flats both with
# ("blue" flats) and without ("red" flats) in order to recover the proper
# response from both regions of the chip, which is undersensitive in the
# blue.  The selection factor here is the header keyword FILTER.

del allflats
del flat_blue
del flat_red
print "Generating file lists..."
hsel *.fits $I 'IMAGETYP == "flat"' > allflats
hsel @allflats $I 'FILTER == "Blue"' > flat_blue
hsel @allflats $I 'FILTER == "Open"' > flat_red
del allflats

# MAKE IMAGE LIST OF BIASES
#
# Make an image list of bias frames.  These file lists are generated
# according to the value of the IMAGETYP header keyword, added at the time
# of integration to the FITS headers.  If the data do not contain biases, an
# empty text file will be written.

del biases
hsel *.fits $I 'IMAGETYP == "zero"' > biases

# MAKE IMAGE LIST OF DARKS
#
# Make an image list of dark frames (if applicable).  This command is 
# usually commented out unless exceedingly long integration times demand
# darks be taken.  The echelle chip is very low noise, so darks are not
# routinely taken with it.  Should you require subtracting darks from your data,
# uncomment the following line and the DARKCOMBINE command later in the script.
# Then in the lines later where the task CCDPROC is invoked, add the following
# to the command string:   dark+ dark=dark_fid

#del darks
#hsel *.fits $I 'IMAGETYP == "dark"' > darks

# MAKE IMAGE LIST OF ARCS
#
# Make an image list of Th-Ar comparison spectra

del arcs
hsel *.fits $I 'IMAGETYP == "comp"' > arcs 

# MAKE IMAGE LIST OF OBJECT SPECTRA
#
# Make an image list of object images

del targets
hsel *.fits $I 'IMAGETYP == "object"' > targets

# MAKE COMPOSITE IMAGE LIST OF OBJECTS AND FLATS
#
# Make an image list consisting of all the object frames and flats for
# the first pass at cosmic ray removal.  This is simply for convenience's
# sake.

del objflat
hsel *.fits $I 'IMAGETYP == "flat"' > objflat
hsel *.fits $I 'IMAGETYP == "object"' >> objflat

# CHANGE FILE PERMISSIONS AND SET DISPAXIS
#
# Dispaxis = 1 (horizontal) or 2 (vertical)

print "Changing file permissions and setting dispaxis..."
!chmod 777 *
hedit *.fits dispaxis 1 add+ ver-

# COSMIC RAY REMOVAL: FIRST PASS
#
# Do first pass at cosmic ray removal with a fairly conservative flux ratio
# threshold.  This will be supplanted by another pass later on which raises
# the threshold a notch to catch any remaining CRs.  The thresholds applied to 
# the images are based on experience with ARCES data, running the COSMICRAYS
# task by hand.  Further testing may result in refinement of these values; 
# alternately, feel free to alter the thresholds with your own values.

print "Cosmic ray removal: first pass..."
cosmicrays @objflat output=" " interac=no threshold=50 fluxratio=5

# CREATE ECHELLE BAD PIXEL MASK
#
# Enter the proto package for generating the bad pixel mask.  You need to have
# a file already in the same directory called "badcols" containing the 
# following plain ASCII text information: 
#
# 788 788 803 2000
# 1683 1683 664 2000
# 102 102 220 2068
# 1285 1285 1793 1836
# 1356 1356 1475 2068
# 1603 1603 1419 1783
# 1383 1383 1906 1944
# 1417 1417 1927 1975
# 982 982 1611 1891
# 491 491 1576 1685
# 569 569 1711 1723
# 654 655 1906 1982
# 854 854 1871 1926
#
# These are the known bad columns on the chip.  You can add any other
# regions to be fixed here as well.
#
# Use the task TEXT2MASK to create the bad pixel mask from the ASCII "badcols"
# file

del echmask.pl
text2mask text="badcols" mask="echmask" ncols=2128 nlines=2068
# ONLY FOR 050717 AND 050718:
#text2mask text="badcols2" mask="echmask" ncols=2068 nlines=2128

# MAKE AVERAGE BIAS (IF APPLICABLE)
#
# Combine biases to yield an average (fiducial) bias

noao
imred
ccdred

zerocombine @biases output="bias_fid"
imdel @biases
del biases

# MAKE AVERAGE DARK FRAME (IF APPLICABLE)
#
# Combine dark frames to yield an average dark.  This step can be 
# commented out if dark correction is not to be made.

#darkcombine @darks output="dark_fid"

# CALIBRATE ARCS, OBJECT AND FLAT FIELD SPECTRA
#
# Calibrate object images and flat field images with the task ccdproc.  The
# calibrations applied at this step are the bad pixel removal, bias subtraction,
# and trimming.  The trim section is hardcoded here.

print "CALIBRATION: REMOVE BAD PIXELS, BIAS, AND TRIM IMAGES"
print "Calibrating object images..."
ccdproc @targets  trimsec=[200:1850,1:2048] fixfile=echmask.pl order=3 niterate=3 zerocor+ darkcor=no flatcor=no trim+ fixpix+ zero=bias_fid order=3 niterate=3 interac=no 

print "Calibrating blue flats..."
ccdproc @flat_blue trimsec=[200:1850,1:2048] fixfile=echmask.pl order=3 niterate=3 zerocor+ darkcor=no flatcor=no trim+ fixpix+ zero=bias_fid order=3 niterate=3 interac=no

print "Calibrating red flats..."
ccdproc @flat_red trimsec=[200:1850,1:2048] fixfile=echmask.pl order=3 niterate=3 zerocor+ darkcor=no flatcor=no trim+ fixpix+ zero=bias_fid order=3 niterate=3 interac=no

print "Calibrating wavecals..."
ccdproc @arcs trimsec=[200:1850,1:2048] fixfile=echmask.pl order=3 niterate=3 zerocor+ darkcor=no flatcor=no trim+ fixpix+ zero=bias_fid order=3 niterate=3 interac=no

# COSMIC RAY REMOVAL: SECOND PASS
#
# Apply the second round of cosmic ray rejection to the calibrated images, raising
# slightly the flux ratio threshold.  In practice this results in the elimination
# of very nearly all the CR's originally present in the data.

#print "Cosmic ray removal: second pass..."
#cosmicrays input=@targets   output=" " threshold=50 fluxratio=11.5 interac=no
#cosmicrays input=@flat_blue output=" " threshold=50 fluxratio=11.5 interac=no
#cosmicrays input=@flat_red  output=" " threshold=50 fluxratio=11.5 interac=no

# COMBINE "RED" AND "BLUE" FLATS SEPARATELY
#
# Separately combine "red" and "blue" flat field frames to produce mean flats
# in each "color"

print "Combining red and blue flats into separate fiducial flats..."
imcombine @flat_blue output=flat_blue_mean.fits combine=median
imcombine @flat_red  output=flat_red_mean.fits combine=median
#imdel @flat_blue
#imdel @flat_red
#del flat_blue
#del flat_red

# MAKE AVERAGE "SUPERFLAT"
#
# Combine the "red" and "blue" mean flats to result in a "superflat" or 
# fiducial flat by which object images will eventually be divided

print "Combining average red and blue flats into a superflat..."
imarith flat_blue_mean.fits + flat_red_mean.fits junk
imarith junk / 2 flat_fid
imdel junk
#imdel flat_blue_mean.fits
#imdel flat_red_mean.fits

# SET DATA TYPE
#
# Set the type of data being extracted to "Echelle". Forced review of the 
# parameters being set is suppressed.

setinstrument echelle review=no

# EXTRACT AND NORMALIZE SUPERFLAT
#
# Magnify superflat by 4 in the cross-dispersion direction.
# Then apply model apertures, recenter, resize, trace, and extract.
# Scattered light subtraction isn't necessary because superflat will be
#   normalized anyway (we only want pixel-to-pixel variation).

print "Resample the superflat in the y direction..."
magnify (input="flat_fid.fits",output="flat_fid.fits",xmag=1,ymag=4)
hedit (images="flat_fid.fits",fields="CCDSEC",value="[200:1850,1:8189]",add=no,addonly=no,delete=no,verify=no,show=yes,update=yes)

print "Modeling and extracting the superflat..."
#apall (input="flat_fid.fits",ref="040110.0024",format="echelle",interac=no,find=no,recenter=yes,resize=yes,edit=no,trace=yes,fittrace=yes,extract=yes,extras=no,review=no,shift=no,width=18,radius=18,ylevel=0.05,background="none")
#apall (input="flat_fid.fits",ref="echtrace130522",format="echelle",interac=no,find=no,recenter=yes,resize=yes,edit=no,trace=yes,fittrace=yes,extract=yes,extras=no,review=no,shift=no,width=18,radius=18,ylevel=0.05,background="none")
apall (input="flat_fid.fits",ref="ref",format="echelle",interac=no,find=no,recenter=yes,resize=yes,edit=no,trace=yes,fittrace=yes,extract=yes,extras=no,review=no,shift=no,width=18,radius=18,ylevel=0.05,background="none")
#imdel flat_fid.fits

print "Normalizing the superflat..."
imcopy ("flat_fid.ec.fits","nonorm_flat_fid.ec.fits")
imdel ("flat_fid.ec.fits",verify-)
sfit (input="nonorm_flat_fid.ec.fits",output="flat_fid.ec.fits",type="ratio",replace=no,wavesca=no,logscal=no,override=yes,interac=no,sample="*",naverag=1,funct="spline3",order=5,low_rej=2,high_rej=0,niterate=10,grow=1)

# APPLY MODEL APERTURES TO WAVECALS
#
# PL: Magnify arcs by 4 in the cross-dispersion direction
#     (because reference image is already magnified).
# Apply model apertures. No resizing, recentering or tracing.
# Also extract spectra here if doing 1D flatfielding, else extract after apflatten

del all.list
cp arcs all.list
list = "all.list"
while (fscan (list,s1) !=EOF) {
  print "Resampling the arc by a factor of 4 in the y direction..."
  magnify (input=s1,output=s1,xmag=1,ymag=4)
  hedit (images=s1,fields="CCDSEC",value="[200:1850,1:8189]",add=no,addonly=no,delete=no,verify=no,show=yes,update=yes)

  print "Applying model apertures to the arc and extracting spectra..."
#  apall (input=s1,ref="040110.0024",format="echelle",interac=no,find=no,recenter=no,resize=no,edit=no,trace=no,fittrace=no,extract=yes,extras=no,review=no,shift=no,background="none")
  apall (input=s1,ref="flat_fid",format="echelle",interac=no,find=no,recenter=no,resize=no,edit=no,trace=no,fittrace=no,extract=yes,extras=no,review=no,shift=no,background="none")
  imdel(s1,ver-)
}

# FLAT FIELD WAVECALS
del arcs_extracted
hsel *.ec.fits $I 'IMAGETYP == "comp"' > arcs_extracted
cp arcs_extracted all.list
list = "all.list"
while (fscan(list,s1) !=EOF) {
  imarith(operand1=s1,op="/",operand2="flat_fid.ec.fits",result=s1)
}

# DISPERSION CALIBRATE WAVECALS
#
# Dispersion calibrate the comparison spectra

print "Dispersion calibrating the arcs..."
#ecreidentify images=@arcs_extracted reference="040110.0025.ec" cradius=2 threshold=50
#ecreidentify images=@arcs_extracted reference="arcnewref.ec" cradius=2 threshold=50
ecreidentify images=@arcs_extracted reference="ref.ec" cradius=2 threshold=50

# remove extracted arcs so we will do them again with object frames
list = "all.list"
setjd (images="@all.list",jd="jd",hjd="",ljd="")
while (fscan (list,s1) !=EOF) {
   imcopy (input=s1,output="w"//s1)
   s2="w"//s1
   refspectra (input=s2,references="@arcs_extracted",answer=yes,sort="JD",group="",time=yes,confirm=no,overrid=yes,assign=yes,select="nearest")
  print dispcor (s2)
  dispcor (input=s2,output=s2,flux=no,linearize=no,log-,verbose=yes)
}

del arcs
del objflat
del .pl
del echmask.pl
