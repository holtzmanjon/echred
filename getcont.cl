# By Pey Lian Lim (5/17/2005)
# Fit continuum to spectra in list and normalize them.
#
# To be called from echred.cl.
#    task getcont = getcont.cl
#    getcont(inputlist=listname)

procedure getcont (input)

char input {prompt = 'Input frame'}
#string *list

begin
#  char path, inlist, s1, inspec, outspec
  char inspec, outspec

#  path = "./"
#  inlist = input

# Open the IRAF task packages to be used in this script
  noao
  onedspec
  images
  imutil

# Get list of inputs
#  list = inlist

# Loop through file list
#  while(fscan(list,s1)!=EOF) {
#    print("Normalizing ",s1)

#    inspec = path//s1//".ec.fits"
#    outspec = path//s1//".norm.ec.fits"
  inspec = "./"//input
  outspec = "fullcont"//input
  imdel outspec

print("doing ",inspec,outspec)
  imreplace (images=inspec,upper=0,value=0)
  imreplace (images=inspec,lower=1000000,value=0)


# Sample all, order 2
    continuum(input=inspec,output=outspec,lines="1:9",type="fit",wavescale=yes,logscale=no,override=yes,listonly=no,logfile="",inter=no,sample="*",funct="spline3",order=2,low_rej=2.,high_rej=0.,niter=10,grow=1,markrej=no,ask="YES")

# Sample all, order 4
    continuum(input=inspec,output=outspec,lines="10:15,61",type="fit",wavescale=yes,logscale=no,override=yes,listonly=no,logfile="",inter=no,sample="*",funct="spline3",order=4,low_rej=2.,high_rej=0.,niter=10,grow=1,markrej=no,ask="YES")

# Sample all, order 6
    continuum(input=inspec,output=outspec,lines="16:18,30,33:60,62:74,76,78:82,85",type="fit",wavescale=yes,logscale=no,override=yes,listonly=no,logfile="",inter=no,sample="*",funct="spline3",order=6,low_rej=2.,high_rej=0.,niter=10,grow=1,markrej=no,ask="YES")

# Sample all, order 3
    continuum(input=inspec,output=outspec,lines="19:20",type="fit",wavescale=yes,logscale=no,override=yes,listonly=no,logfile="",inter=no,sample="*",funct="spline3",order=3,low_rej=2.,high_rej=0.,niter=10,grow=1,markrej=no,ask="YES")

# Sample all, order 5
    continuum(input=inspec,output=outspec,lines="21:29",type="fit",wavescale=yes,logscale=no,override=yes,listonly=no,logfile="",inter=no,sample="*",funct="spline3",order=5,low_rej=2.,high_rej=0.,niter=10,grow=1,markrej=no,ask="YES")

# Ap 31
    continuum(input=inspec,output=outspec,lines="31",type="fit",wavescale=yes,logscale=no,override=yes,listonly=no,logfile="",inter=no,sample="6548.24:6553.42,6573.27:6687.13",funct="spline3",order=6,low_rej=2.,high_rej=0.,niter=10,grow=1,markrej=no,ask="YES")

# Ap 32
    continuum(input=inspec,output=outspec,lines="32",type="fit",wavescale=yes,logscale=no,override=yes,listonly=no,logfile="",inter=no,sample="6473:6555.28,6576:6609.9",funct="spline3",order=6,low_rej=2.,high_rej=0.,niter=10,grow=1,markrej=no,ask="YES")

# Ap 75
    continuum(input=inspec,output=outspec,lines="75",type="fit",wavescale=yes,logscale=no,override=yes,listonly=no,logfile="",inter=no,sample="4332.39:4335.45,4346.12:4423.55",funct="spline3",order=6,low_rej=2.,high_rej=0.,niter=10,grow=1,markrej=no,ask="YES")

# Ap 77
    continuum(input=inspec,output=outspec,lines="77",type="fit",wavescale=yes,logscale=no,override=yes,listonly=no,logfile="",inter=no,sample="4267:4336.67,4345.6:4356.81",funct="spline3",order=4,low_rej=2.,high_rej=0.,niter=10,grow=1,markrej=no,ask="YES")

# Ap 83
    continuum(input=inspec,output=outspec,lines="83",type="fit",wavescale=yes,logscale=no,override=yes,listonly=no,logfile="",inter=no,sample="4167:4109,4081.7:4093.75",funct="spline3",order=5,low_rej=2.,high_rej=0.,niter=10,grow=1,markrej=no,ask="YES")

# Ap 84
    continuum(input=inspec,output=outspec,lines="84",type="fit",wavescale=yes,logscale=no,override=yes,listonly=no,logfile="",inter=no,sample="4052.1:4093.9,4108.4:4137.4",funct="spline3",order=5,low_rej=2.,high_rej=0.,niter=10,grow=1,markrej=no,ask="YES")

# Crude fitting for Aps 86-107
    continuum(input=inspec,output=outspec,lines="86:107",type="fit",wavescale=yes,logscale=no,override=yes,listonly=no,logfile="",inter=no,sample="*",funct="spline3",order=4,low_rej=2.,high_rej=0.,niter=10,grow=1,markrej=no,ask="YES")
#  }
end
