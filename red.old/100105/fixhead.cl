# fixes REMARK echelle headers to better match TUI headers

del Expo.lst
del hdevide.lst
!hdcor
del Expo.lst
del hdevide.lst

hedit *.fits "GAIN" "3.8" add+ ver-
hedit *.fits "RDNOISE" "7" add+ ver-
hedit *.fits "DETSIZE" "[1:2048,1:2048]" add+ ver-
hedit *.fits "DATASEC" "[1:2048,1:2048]" add+ ver-
hedit *.fits "BIASSEC" "[2071:2126,2:2047]" add+ ver-
#hedit *.fits DATE-OBS "(DATE)" add+ ver-
hedit *.fits DATE-OBS "(UTDATE//'T'//UT)" add+ ver-
hedit *.fits EXPTIME "(OPENTIME)" add+ ver-
hedit *.fits EQUINOX "(EPOCH)" add+ ver-
hedit *.fits UTC-OBS "(UT)" add+ ver-

del allflats
del flat_blue
del flat_red
hsel *.fits $I 'IMAGETYP == "flat"' > allflats
hsel @allflats $I 'EFILTER == 2' > flat_blue
hsel @allflats $I 'EFILTER != 2' > flat_red
hedit @flat_blue FILTER "Blue" add+ ver-
hedit @flat_red FILTER "Open" add+ ver-

del allflats
del flat_blue
del flat_red

