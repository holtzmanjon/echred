$cp targets targets.dat
open input ./targets.dat
stat n=count[input]
setdir pr dir=/home/holtz/procedure/3.5m
call getdet 16
do i=1,n
  string file {input}
  rd 1 ./{file}
  zap 1 size=1,5 noisemod gain=gain rn=rn positive
  $mv {file} {file}.old
  wd 1 ./{file}
end_do
end
