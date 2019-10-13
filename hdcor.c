/* This programs finds a *.fits files in the current  directory
   and finds STARTDAT and STARTTIM keywords in a fits file header.
   Then converts TOTALTIM into UTMIDDLE and puts a middle exposure time 
   there. The same with STARTDAT 
   STARTDAT is converted into  MID-DATE and the date corresponding to the
   middle exposure time is placed there. The code will not act on
   files, which doesn't have STARTDAT or STATTIM keywords. Other
   words it's safe to run it on the same file again and again.
   Keeps track of the data for the middle exposure and changes it
   also (on the monts and years borders). It will not work properly if
   the date change happens on the even year.
   
   Also prepares a list of files to be devided by their integration time. 
   Biases and Arcs are not included int the list.
*/   
 

#include<stdio.h>
#include<ctype.h>
#include<stdlib.h>
#include<string.h>
#include<stdarg.h>
#include<math.h>
long int fpl;                             /* Position in a fsuh file  */
 
main( )

{
char header[20], headrest[90],line_lst[100], slow[20], *iwere;
int i, jest, iyy,imm,idd, ih,im,is, sh,sm,ss, isarc=0; 
long int pl, plSTARTDAT, plTOTALTIM, plSTARTTIM;
double integr=0, midtime, iss;
char name[35], arc[35];
FILE *fsuh, *flst, *fdevide;

strcpy(slow,"=* ");
//system("ls -1 *fits > Expo.lst"); 
system("ls -1 *fits >> Expo.lst"); 

flst = fopen("Expo.lst","rt");          /* A list of Exposure files  */
fdevide=fopen("hdevide.lst","wt");      /* A script file for iraf    */        


while( fgets(line_lst,80,flst) != NULL )   /* reads fits files from the list */
{  
  sscanf( line_lst,"%s",name );
  if ( (fsuh=fopen( name, "r+")) ==NULL )   { 
     printf("\n Wrong file name: %s\n ",name); 
     fclose(fsuh); 
     exit(1); 
     }
  {
    jest=0;
    
    for (i=0; i< 70;i++) {
      fread(header, 8, 1, fsuh); 
      header[8]='\0'; 
      if (strstr(header,"END     ") != NULL) break;

      if (strstr(header,"STARTTIM") != NULL) {
        plSTARTTIM=ftell(fsuh)-8;
        fread(headrest,72,1,fsuh); 
        // read the STARTTIM value ....
        iwere=strstr(headrest,":");  // find the first occurance of ":"
        sscanf(iwere-2,"%2d:%2d:%2d",&ih,&im,&is);
        sh=ih; sm=im; ss=is;
        jest++;
//        printf("found STARTTIM jest=%d  %2d:%2d:%2d\n",jest, ih,im,is);
      }  else if( strstr(header,"STARTDAT") != NULL) { 
        plSTARTDAT=ftell(fsuh)-8;
        fread(headrest,72,1,fsuh);
        // read the STARTDAT value ....  
        iwere=strstr(headrest,"/");  // find the first occurance of "/" 
        sscanf(iwere-2,"%2d/%2d/%4d",&imm,&idd,&iyy);
        jest++;
//        printf("found STARTDAT jest=%d plSTARTDAT:%d  %2d/%2d/%4d\n",jest, plSTARTDAT, imm,idd,iyy);
      } else if( strstr(header,"OPENTIME") != NULL) { 
        fread(headrest,72,1,fsuh);
        sscanf(headrest+1,"%lf",&integr);
        jest++;
//        printf("found OPENTIME jest=%d  int=%lf\n",jest, integr);
      } else if( strstr(header,"TOTALTIM") != NULL) { 
        plTOTALTIM=ftell(fsuh)-8;
        fread(headrest,72,1,fsuh); 
        jest++;
//        printf("found TOTALTIM jest=%d  plTOTALTIM:%d\n",jest, plTOTALTIM);
      } else if( strstr(header,"IMAGETYP") != NULL) {
        //looking for an arc:
        fread(headrest,72,1,fsuh); 
        // IMAGETYP = 'comp'....
        iwere=strstr(headrest,"'");  // find the first occurance of "'"
        sscanf(iwere,"%s",arc); if(strstr(arc,"comp")) isarc=1;
      }  
/*
        else
      if( strstr(header,"UTDATE  ") != NULL) 
        { 
        pl=ftell(fsuh)-8;
        fread(headrest,72,1,fsuh);
        // read the UTDATE value ....
        iwere=strstr(headrest,"-");  // find the first occurance of "-"
        sscanf(iwere-4,"%4d-%2d-%2d",&iyy,&imm,&idd);
        jest++;
//        printf("found UTDATE jest=%d pl=%d  %4d-%2d-%2d\n",jest, pl, iyy,imm,idd);
        }
*/
      else  
        fread(headrest,72,1,fsuh);

      if (jest==4) break;
    }

    if (jest==4) {
      midtime=ih+im/60.+is/3600. + integr/7200.;
      if (midtime >= 24.) { 
        midtime=midtime-24.; 
        idd++;
        // check date change ...
        if(imm==1  && idd>31) { imm++; idd=1; break;} 
        if(imm==2  && idd>28) { imm++; idd=1; break;}  // doesn't work for even years...
        if(imm==3  && idd>31) { imm++; idd=1; break;} 
        if(imm==4  && idd>30) { imm++; idd=1; break;} 
        if(imm==5  && idd>31) { imm++; idd=1; break;}
        if(imm==6  && idd>30) { imm++; idd=1; break;} 
        if(imm==7  && idd>31) { imm++; idd=1; break;}
        if(imm==8  && idd>31) { imm++; idd=1; break;}
        if(imm==9  && idd>30) { imm++; idd=1; break;} 
        if(imm==10 && idd>31) { imm++; idd=1; break;}
        if(imm==11 && idd>30) { imm++; idd=1; break;} 
        if(imm==12 && idd>31) { iyy++; imm=1; idd=1;}
        sprintf(headrest,"MID-DATE= '%02d/%02d/%4d'****                                                             ",imm,idd,iyy);
        fseek(fsuh,plSTARTDAT,SEEK_SET);
        fwrite(headrest,1,80,fsuh); 
      } 
    
      ih=(int)midtime;
      im=(int)((midtime-ih)*60.);
      iss=(midtime-ih-im/60.)*3600.;

      printf("%-20s   STARTDAT: %02d/%02d/%4d ,  UTMIDDLE %02d:%02d:%02.0lf\n",name,imm,idd,iyy,ih,im,iss);

      sprintf(headrest,"MID-DATE= '%02d/%02d/%4d'                                                                 ",imm,idd,iyy);
//    sprintf(headrest,"STARTDAT= '%02d/%02d/%4d'                                                               ",imm,idd,iyy);
      fseek(fsuh,plSTARTDAT,SEEK_SET);
      fwrite(headrest,1,80,fsuh); 

      sprintf(headrest,"UTMIDDLE= '%02d:%02d:%02.0lf'                                                             ",ih,im,iss);
      fseek(fsuh,plTOTALTIM,SEEK_SET);
      fwrite(headrest,1,80,fsuh);

      sprintf(headrest,"STARTTIM= '%02d:%02d:%02d'                                                                ",sh,sm,ss);
      fseek(fsuh,plSTARTTIM,SEEK_SET);
      fwrite(headrest,1,80,fsuh);
    } else
      printf("%-20s   header not changed\n",name);

   /* Prepare a list of file to be devided by their integration time */
   /* Excludes biases (integr =0 and ARCs: IMAGETYP = 'comp'         */
    if (integr > 0.1 && isarc==0 ) 
      fprintf(fdevide,"imarith %s / %-8.1lf %s\n",name,integr,name);         
    else 
      isarc=0;
     
    fclose(fsuh);
  }
   
}    /* end if while( ...  */

fclose(fdevide);
fclose(flst);  /* close the list of fits files */
}  /* END of the program */
/*########################################################################*/


