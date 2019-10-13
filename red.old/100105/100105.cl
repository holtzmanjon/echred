begin
$date
del logfile
del .pl
task getcont = getcont.cl
task getvel = getvel.cl
task getascii = getascii.cl
noao
imred
ccdred
proto
twod
apex
echelle
images
imgeom
generic
astutil
onedspec
crutil
imcopy /home/holtz/analysis/echred/raw/100105/100105.0021.fits ./100105.0021.fits 
hedit 100105.0021.fits IMAGETYP comp add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0002.fits ./100105.0002.fits 
hedit 100105.0002.fits IMAGETYP flat add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0003.fits ./100105.0003.fits 
hedit 100105.0003.fits IMAGETYP flat add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0004.fits ./100105.0004.fits 
hedit 100105.0004.fits IMAGETYP flat add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0005.fits ./100105.0005.fits 
hedit 100105.0005.fits IMAGETYP flat add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0006.fits ./100105.0006.fits 
hedit 100105.0006.fits IMAGETYP flat add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0007.fits ./100105.0007.fits 
hedit 100105.0007.fits IMAGETYP flat add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0008.fits ./100105.0008.fits 
hedit 100105.0008.fits IMAGETYP zero add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0009.fits ./100105.0009.fits 
hedit 100105.0009.fits IMAGETYP zero add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0010.fits ./100105.0010.fits 
hedit 100105.0010.fits IMAGETYP zero add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0011.fits ./100105.0011.fits 
hedit 100105.0011.fits IMAGETYP zero add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0012.fits ./100105.0012.fits 
hedit 100105.0012.fits IMAGETYP zero add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0013.fits ./100105.0013.fits 
hedit 100105.0013.fits IMAGETYP zero add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0014.fits ./100105.0014.fits 
hedit 100105.0014.fits IMAGETYP zero add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0015.fits ./100105.0015.fits 
hedit 100105.0015.fits IMAGETYP zero add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0016.fits ./100105.0016.fits 
hedit 100105.0016.fits IMAGETYP zero add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0017.fits ./100105.0017.fits 
hedit 100105.0017.fits IMAGETYP zero add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0018.fits ./100105.0018.fits 
hedit 100105.0018.fits IMAGETYP object add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0019.fits ./100105.0019.fits 
hedit 100105.0019.fits IMAGETYP object add+ ver-
imcopy /home/holtz/analysis/echred/raw/100105/100105.0020.fits ./100105.0020.fits 
hedit 100105.0020.fits IMAGETYP object add+ ver-
hedit *.fits BIASSEC [2072:2126,2:2047] add+ ver-
cl < prep.cl
!xvista < xvista.inp
cl < obj.cl
imsum input=mash100105.0018.ec.fits,mash100105.0019.ec.fits,mash100105.0020.ec.fits output=TYC_1987-00958-1.mash.ec.fits
imsum input=cont100105.0018.ec.fits,cont100105.0019.ec.fits,cont100105.0020.ec.fits output=TYC_1987-00958-1.cont.ec.fits
imarith sig100105.0018.ec.fits * sig100105.0018.ec.fits sig2100105.0018.ec.fits
imarith sig100105.0019.ec.fits * sig100105.0019.ec.fits sig2100105.0019.ec.fits
imarith sig100105.0020.ec.fits * sig100105.0020.ec.fits sig2100105.0020.ec.fits
imsum input=sig2100105.0018.ec.fits,sig2100105.0019.ec.fits,sig2100105.0020.ec.fits output=sig2TYC_1987-00958-1.ec.fits
imfunc sig2TYC_1987-00958-1.ec.fits TYC_1987-00958-1.sig.ec.fits function="sqrt" verbose-
imdel sig2TYC_1987-00958-1.ec.fits
imdel sig2100105.0018.ec.fits
imdel sig2100105.0019.ec.fits
imdel sig2100105.0020.ec.fits
cl < combine.cl
!awk -F. '{print $1}' all.list > rv.lis
getvel(inputlist="rv.lis")
$date
logout
