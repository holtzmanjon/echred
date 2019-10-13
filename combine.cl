noao
onedspec

int idx
char root
string log

del all.list
hsel *.mash.ec.fits $I 'IMAGETYP == "object"' > targets
cp targets all.list
list = "all.list"
while (fscan (list,s1) !=EOF) {

 idx  = stridx(".",s1) - 1
 root = substr(s1,1,idx)

print (root)
 s1=root//".mash.ec.fits"
 s2=root//".nonorm.fits"
 imdel(s2,verify-)
 s3=root//".nonorm.log.fits"
 imdel(s3,verify-)
 scombine (input=s1,output=s2,group="all",combine="sum",log=no)
# scombine (input=s1,output=s3,group="all",combine="sum",log=yes)
# scomb s1 s2 group="all" combine="sum" log=no

 imdel mashnorm.ec.fits
 imarith (operand1=root//".mash.ec.fits",op="/",operand2=root//".cont.ec.fits",result="mashnorm.ec.fits")
 imdel signorm.ec.fits
 imarith (operand1=root//".sig.ec.fits",op="/",operand2=root//".cont.ec.fits",result="signorm.ec.fits")
 imdel sig2norm.ec.fits
 imarith (operand1="signorm.ec.fits",op="*",operand2="signorm.ec.fits",result="sig2norm.ec.fits")
 imdel numer.ec.fits
 imarith (operand1="mashnorm.ec.fits",op="/",operand2="sig2norm.ec.fits",result="numer.ec.fits")
 imdel weight.ec.fits
 imarith (operand1="1.0",op="/",operand2="sig2norm.ec.fits",result="weight.ec.fits")

 imdel numer.fits 
 scomb numer.ec.fits numer.fits group="all" combine="sum" log=no
 imdel numer.log.fits
# scomb numer.ec.fits numer.log.fits group="all" combine="sum" log=yes
 imdel weight.fits 
 scomb weight.ec.fits weight.fits group="all" combine="sum" log=no
 imdel weight.log.fits
# scomb weight.ec.fits weight.log.fits group="all" combine="sum" log=yes

 s2=root//".fits"
 imdel(s2,verify-)
 imarith (operand1="numer.fits",op="/",operand2="weight.fits",result=root//".fits")
 s2=root//".sig.fits"
 imdel(s2,verify-)
 imarith (operand1="1.0",op="/",operand2="weight.fits",result=root//".sig.fits")
 imfunc (input=root//".sig.fits",output=root//".sig.fits",function="sqrt",verbose-)

 s2=root//".log.fits"
 imdel(s2,verify-)
# imarith (operand1="numer.log.fits",op="/",operand2="weight.log.fits",result=root//".log.fits")
 s2=root//".sig.log.fits"
 imdel(s2,verify-)
# imarith (operand1="1.0",op="/",operand2="weight.log.fits",result=root//".sig.log.fits")
# imfunc (input=root//".sig.log.fits",output=root//".sig.log.fits",function="sqrt",verbose-)
 
 imdel mashnorm.ec.fits
 imdel signorm.ec.fits
 imdel sig2norm.ec.fits
 imdel numer.ec.fits
 imdel weight.ec.fits
 imdel numer.fits
 imdel weight.fits
 imdel numer.log.fits
 imdel weight.log.fits
}

