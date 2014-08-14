
alias bj='bjobs -w'
alias isub='bsub -q interactive -Is bash'
alias isub8='bsub -n 4 -R span[hosts=1] -q interactive -Is bash'


joblist(){
    ## use default joblist-filename or user-provided name
    if [ $# -ne 1 ]; then
        joblistFile=".jobs"
    else
        joblistFile=$1
    fi

    # add the job-id to the list
    cat - | tee /dev/stderr |  cut -f2 -d" " | sed 's/[<>]//g' >> $joblistFile
}
export -f joblist


jlistKill(){
    if [ $# -ne 1 ]; then
        joblistFile=".jobs"
    else
        joblistFile=$1
    fi

#    cat $joblistFile | xargs -L1 bkill
    cat $joblistFile | while read id ; do bkill "$id" ; done
}
export -f jlistKill


killByName(){
    echo killing jobs which include: $1 ...
    bjobs -w | grep $1 | awk '{ print $1 }'   | while read id ; do bkill $id ; done
}
export -f killByName


jlistBtop(){
    if [ $# -ne 1 ]; then
        joblistFile=".jobs"
    else
        joblistFile=$1
    fi

    cat $joblistFile | xargs -L1 btop
}
export -f jlistBtop


jlistStatus(){
    if [ $# -ne 1 ]; then
        joblistFile=".jobs"
    else
        joblistFile=$1
    fi

    bjobs -w | grep -Ff $joblistFile
}
export -f jlistStatus


jlistReport(){
    if [ $# -ne 1 ]; then
        joblistFile=$(ls -a | grep "cluster_snapshots.txt" | sed "s/.cluster_snapshots.txt//g")
    else
        joblistFile=$1
    fi

    echo "reportName='$joblistFile'; source('http://dl.dropboxusercontent.com/u/113630701/rlibs/BjobsReport.R',local=T)" | R --no-save --no-restore 2>&1 > /dev/null
}
export -f jlistReport


wait4jobs(){
    ## use default joblist-filename or user-provided name
    if [ $# -ne 1 ]; then
        joblistFile=".jobs"
    else
        joblistFile=$1
    fi

    # wait until all jobs from the list are done
    sleep 2
    while [ -n "$(bjobs 2>&1 | grep -f $joblistFile)" ]; do
        sleep 15; ## or use bparams output
    done

    # remove the joblist-file
    rm $joblistFile
}
export -f wait4jobs


blockScript(){
    if [ $# -ne 1 ]; then
        joblistFile=".jobs"
    else
        joblistFile=$1
    fi

    joblist $joblistFile
    echo "waiting now for joblist:
     $(cat $joblistFile)"

    ## add jobs to top of queue
    jlistBtop $joblistFile

    wait4jobs $joblistFile
}
export -f blockScript



wait4jobsReport(){
    ## use default joblist-filename or user-provided name
    if [ $# -ne 1 ]; then
        joblistFile=".jobs"
    else
        joblistFile=$1
    fi

#    rm $joblistFile.cluster_usage.txt $joblistFile.cluster_snapshots.txt

    # wait until all jobs from the list are done
    sleep 2
    while [ -n "$(bjobs 2>&1 | grep -f $joblistFile)" ]; do
        sleep 15; ## or use bparams output
        export curTime=$(date +"%d-%m-%Y_%H:%M:%S")
#        bjobs -W $(cat $joblistFile ) 2>/dev/null | sed 's/ \+/\t/g' | tail -n +2  | awk -v OFS='\t' '{print $0, ENVIRON["curTime"]}'  >> $joblistFile.cluster_snapshots.txt
        bjobs -W $(cat $joblistFile ) 2>/dev/null | sed 's/ \+/\t/g' | tail -n +2  | awk -v OFS='\t' '{print $0, ENVIRON["curTime"]}'  >> $joblistFile.cluster_snapshots.txt
    done

#    bjobs -W $(cat $joblistFile )  >> $joblistFile.cluster_usage.txt
    echo "reportName='$joblistFile'; source('http://dl.dropbox.com/u/113630701/rlibs/BjobsReport.R',local=T)" | R --vanilla 2>&1 > /dev/null
#    echo "source('http://dl.dropbox.com/u/113630701/rlibs/BjobsReport.R',local=T)" | R --vanilla 2>&1 > /dev/null

    # remove the joblist-file
    rm $joblistFile
}
export -f wait4jobsReport


blockScriptReport(){
    if [ $# -ne 1 ]; then
        joblistFile=".jobs"
    else
        joblistFile=$1
    fi

    joblist $joblistFile
    echo "waiting now for joblist:
     $(cat $joblistFile)"

    ## add jobs to top of queue
    jlistBtop $joblistFile

    wait4jobsReport $joblistFile
}
export -f blockScriptReport


mailme(){
    echo "Subject:"$1 "$2" | sendmail -v $(whoami)@mpi-cbg.de > /dev/null ;
}
export -f mailme


lsloop(){
    while :
    do
        lsload | sort -k1
        sleep 1
    done
}


bjloop(){
    while :
    do
        echo "----------------------------------------------------------------------------------------------------"
        ## http://theunixshell.blogspot.de/2012/12/print-first-80-characters-in-line.html
        bjobs -w | head -n 50 | cut -c1-100
        bjobs | awk '{print $3}' | sort | uniq -c | head -n2
        sleep 2
    done
}


bstatus(){ bjobs -u all | awk '{print $2 " " $4}' | sort | uniq -c ; }


bjsloop(){
    while :
    do
        bjobs | grep short |  head -n 50
        sleep 1
    done
}

retouch(){
    find $1 | xargs -n1 touch
}
export -f retouch


# old output redirection scheme
#mysub(){
#    if [ $# -lt 2 ]; then echo "Usage: mysub <jobname> <script> [<additional bsub arguments>]"; return; fi
#
#    jobName=$1; shift
#    jobCmd=$1; shift
#
#    bsub -e $jobName.err.log -o $jobName.out.log -J $jobName $@ "$jobCmd"
#}
mysub(){
    if [ $# -lt 2 ]; then echo "Usage: mysub <jobname> <script> [<additional bsub arguments>]"; return; fi

    jobName=$(echo $1| tr ' ' '_'); shift
    jobCmd=$1; shift

    bsub  -J $jobName $@ "( $jobCmd ) 2>$jobName.err.log 1>$jobName.out.log"
}
export -f mysub
#mysub testjob "echo test; echo  blabla 1>&2;" -q medium


## really needed ??
#rm_emptylogs(){ find . -maxdepth 1 -name ".log" -type f -empty -print0 | xargs -0 echo rm -f ; }
#export -f rm_emptylogs


ziprm(){
    if [ $# -lt 2 ]; then echo "Usage: ziprm <tarbasename> [<file>]+"; return; fi

    tarName=$(date +'%y%m%d')_"$1".tar.gz; shift
    tar czf $tarName $@; rm $@;
}
export -f ziprm


## lock a node
nlock(){
    bsub -J "node_locker" -R span[hosts=1] -n 6 -q long 'echo "locked $HOSTNAME" >> ~/locked_worker.txt; sleep 10h' | joblist /tmp/tmp.gHDskZ7c77

    mailme "locked node: $(tail -n1 ~/locked_worker.txt | cut -d' ' -f2)"
#    ssx $(tail -n1 ~/locked_hosts.txt | cut -d' ' -f2)
#    jlistKill $tmpJoblistFile
}
export -f nlock

#isubNode(){
#    tmpJoblistFile=$(mktemp)
#    bsub -J "node_locker" -R span[hosts=1] -n 8 -q long 'echo "locked $HOSTNAME" >> ~/locked_hosts.txt; sleep 10h'  | wait4jobs $tmpJoblistFile
#    ssx $(tail -n1 ~/locked_hosts.txt | cut -d' ' -f2)
#    jlistKill $tmpJoblistFile
#}


