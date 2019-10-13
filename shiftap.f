C program to shift centers of reference apertures up or down
C  output file should be named aprefap, or else name needs to
C  be changed in output file
	character line*80,a*16

C	open(1,file='aprefap',status='old')
	open(1,file='apnewap',status='old')

1	read(1,'(a)',end=99) line
	if (index(line,'center') .gt. 0) then
	  read(line(9:),*) x,y
C	  y=y-10
	  y=y*4
	  print 101,char(9),char(9),x,y
101	  format(a,'center',a,f5.0,f9.3)
        else
         do i=1,len(line)
           if (line(i:i) .ne. ' ') l=i
         end do
         print '(a)', line(1:l)
        endif
	goto 1

99	stop
	end
