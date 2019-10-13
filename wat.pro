parameter ncard
$'rm' wat2.dat
do i=1,ncard
  string card 'wat2_%i3.3' i
  printf '{1:{card}}' >>./wat2.dat
end_do
$'rm' spec.out spec.dat
! edit wat2.dat for lines with leading spaces
$cat wat2.dat | tr -d \\n | sed 's/\"/ /g' | sed "s/'//g" | sed 's/spec/\nspec/g' | tail -n +3 >./spec.out
$awk -f ../wat.awk spec.out >./spec.html
END
