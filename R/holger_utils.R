
xtab<- function(mydata){
    tFile<-tempfile(fileext=".csv",tmpdir="~/tmp")
    write.table(mydata, file=tFile, row.names=F, sep=",")

    if(str_detect(R.version$platform, "linux")){
        system(paste("ssh bioinfo-mac-6-wifi 'open -a /Applications/XTabulator.app/ /Volumes/bioinfo/tmp/", basename(tFile), "'", sep=""))
    }else{
        system(paste("open -a /Applications/XTabulator.app/ ", tFile))
    }
}

xtabh <- function(mydata, rows=100) xtab(head(mydata, rows))


## todo remove this
TAB <- "\t"

xls <- function(data, remoteDesktop="bioinfo-mac-6.mpi-cbg.de"){

#    isRemote=str_detect(R.version$platform, "linux")


    if(str_detect(R.version$platform, "linux")){
        tFile<-tempfile(fileext=".tsv",tmpdir="~/tmp")

        ## http://linux.icydog.net/ssh/piping.php
        write.table(data, file=pipe(concat("ssh brandl@",remoteDesktop," 'cat - >",tFile,"'")), row.names=F, sep=TAB, quote=F)
#        browser()

#        system(paste("ssh ",remoteDesktop," 'open -a \"/Applications/_MPI_Applications/Microsoft Office 2011/Microsoft Excel.app\" ", tFile, "'", sep=""))
        system(format(paste("ssh ",remoteDesktop," 'open -a \"/Applications/_MPI_Applications/Microsoft Office 2011/Microsoft Excel.app\" ", tFile, "'", sep="")))

    }else{
        tFile<-tempfile(fileext=".csv")
        write.table(data, file=tFile, row.names=F, sep=",")
        system(paste("open -a '/Applications/Microsoft Excel' ", tFile))
    }
}

xlsh <- function(mydata, rows=100) xls(head(mydata, rows))


