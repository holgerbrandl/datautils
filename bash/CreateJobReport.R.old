#!/usr/bin/env Rscript

#sessionInfo()


devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/v1.20/R/core_commons.R")
devtools::source_url("https://raw.githubusercontent.com/holgerbrandl/datautils/v1.20/R/ggplot_commons.R")

require_auto(lubridate)


if(!exists("reportName")){
    argv = commandArgs(TRUE)

    if(length(argv) == 0){
        reportName=".jobs"
        # reportName=".ipsjobs"
        # reportName=".trinjob"
        # reportName=".blastn"
        # reportName=".failchunksblastx"
    #    stop("Usage: RemoveContaminants.R <assemblyBaseName>")
    }else{
        reportName=argv[1]
    }
}

reportNiceName <- str_replace_all(reportName, "^[.]", "")
#> # Job Report:  `r reportNiceName`


echo("processing job report for '", reportName,"'")

jobData <- read.table(paste0(reportName, ".cluster_snapshots.txt"), header=F, fill=T) %>% as.df() %>%
    set_names(c("jobid", "user", "stat", "queue", "from_host", "exec_host", "job_name", "submit_time", "proj_name", "cpu_used", "mem", "swap", "pids", "start_time", "finish_time", "snapshot_time")) %>%
    transform(jobid=factor(jobid)) %>%
    arrange(jobid) %>%
    subset(stat=="RUN")

if(nrow(jobData)==0){
    system(paste("mailme 'no jobs were run in  ",normalizePath(reportName),"'"))
    warning(paste("no jobs were run in  ",normalizePath(reportName)))
    stop(-1)
}

#jobData %>% count(jobid) %>% nrow


## extract multi-threading number
jobData %<>%    transform(num_cores=str_match(exec_host, "([0-9]+)[*]n")[,2]) %>% mutate(num_cores=ifelse(is.na(num_cores), 1, num_cores))



jobData %>% count(exec_host)

jobData %>% select(submit_time, start_time, finish_time) %>% head
#    filter(finish_time!="-") %>% head

#parse_date_time(ac("00:00:00.00"), c("%d:%H:%M.%S"))
#parse_date_time(ac("00:04:55.18"), c("%d:%H%M%S"))
## parse the submission time
curYear=str_match(ac(jobData$snapshot_time[1]), "-([0-9]*)_")[,2]
convertTimes <- function(someDate) parse_date_time(paste0(curYear, ac(someDate)), c("%Y/%m/%d-%H%M%S"))
#convertedTimes <- colwise(convertTimes, .(submit_time, start_time, finish_time))(jobData)
#jobData <- cbind(subset(jobData, select=!(names(jobData) %in% names(convertedTimes))), convertedTimes)

jobData %<>% mutate_each(funs(convertTimes), submit_time, start_time, finish_time)


jobData <- transform(jobData, snapshot_time=parse_date_time(ac(snapshot_time), c("%d-%m-%y_%H%M%S")))


splitCPU <- str_split_fixed(jobData$cpu_used, "[.]", 2)[,1]
splitCPUhms <- str_split_fixed(splitCPU, ":", 3)
cpuSecs <- 3600*as.numeric(splitCPUhms[,1]) + 60*as.numeric(splitCPUhms[,2]) + as.numeric(splitCPUhms[,3])
#splitCPU <- str_sub(splitCPU, 2, str_length(splitCPU))

#as.numeric(as.difftime(jobData[22,]$cpu_used_hms, units="secs"))
#jobData <- mutate(jobData, cpu_used_hms=hms(ac(splitCPU)), cpu_used_secs=as.numeric(as.difftime(cpu_used_hms, units="secs")), cpu_used_hours=cpu_used_secs/3600)
jobData <- mutate(jobData, cpu_used_secs=cpuSecs, cpu_used_hours=cpu_used_secs/3600)
jobData <- mutate(jobData, exec_time=difftime(snapshot_time, start_time, units="secs"), exec_time_min=as.numeric(exec_time)/60, exec_time_hours=as.numeric(exec_time)/3600)


## add the queue limits
wallLimits <- c(short=1, medium=8, long=96)
jobData <- mutate(jobData, queueLimit=wallLimits[ac(queue)])


#tt <- head(subset(jobData, is.na(cpu_used_secs)), 100)
#subset(jobData, cpu_used_secs==max(jobData$cpu_used_secs))
#with(jobData, as.data.frame(table(is.na(cpu_used_secs))))

if(max(jobData$cpu_used_secs)==0){
    stop(echo("stopping job report generation for", reportName, "because no cpu time has been consumed"))
    quit()
}


## todo use rollapply to calculate better normalized cpu usage overtime
#ggplot(jobData, aes(exec_time_min, cpu_used_secs/(60*exec_time_min), group=jobid)) + geom_line(alpha=0.3) + ggtitle("normalized cpu usage")
#ggsave2()


save(jobData, file=paste0(reportName, ".cluster_snapshots.RData"))
#jobData <- local(get(load(concat(reportName, ".cluster_snapshots.RData"))))

#ggplot(jobData, aes(exec_time_min, cpu_used_secs, group=jobid)) + geom_line(alpha=0.3) + geom_smooth() + ggtitle("accumulated cpu usage")
ggplot(jobData, aes(exec_time_hours, cpu_used_hours, group=jobid)) + geom_line(alpha=0.3)  + ggtitle("accumulated cpu usage") + geom_vline(aes(xintercept=queueLimit), color="red")

#### ussage per time interval
jobDataSlim <- with(jobData, data.frame(jobid,  num_cores, cpu_used_secs, exec_time=as.numeric(exec_time)))
jobDataCPUChange = ddply(jobDataSlim, .(jobid), subset, diff(cpu_used_secs)!=0)
smoothData <- ddply(jobDataCPUChange, .(jobid), mutate, exec_period=c(NA, diff(as.numeric(exec_time))), cpu_usage_in_period=c(NA, diff(cpu_used_secs)))
smoothData[is.na(smoothData)] <- 0

#ggplot(smoothData, aes(exec_time, cpu_usage_in_period, color=jobid)) + geom_line()
ggplot(subset(smoothData, cpu_usage_in_period>0), aes(exec_time/3600, cpu_usage_in_period/(exec_period* as.numeric(as.character(num_cores))), color=num_cores, group=jobid)) +
    geom_line(alpha=0.3) +
    xlab("exec time [hours]") +
    ylab("core normalized cpu usage") # + scale_color_discrete(name="jobid")



#######################################################################################################################
### sumarize the jobs
jobSummaries <- mutate(subset(plyr::arrange(jobData, -1* exec_time), !duplicated(jobid)), pending_time=difftime(start_time, submit_time,  units="secs"), pending_time_min=as.numeric(pending_time)/60)
jobSummaries <- transform(jobSummaries, jobid=reorder(jobid, as.numeric(jobid)))


#ggplot(jobSummaries, aes(pending_time_min)) + geom_histogram() + ggtitle("pending times") + coord_flip()
if(nrow(jobSummaries)<50){
    ggplot(jobSummaries, aes(reorder(jobid, -as.numeric(jobid)), pending_time_min/60)) + geom_bar(stat="identity") + ggtitle("pending times") + coord_flip() + xlab("job id")
}else{
    ggplot(jobSummaries, aes(as.numeric(jobid), pending_time_min/60)) + geom_area() + ggtitle("pending times")+xlab("job_nr") + ylab("pending time [h]")
}
#ggsave2(p=reportName)

if(nrow(jobSummaries)<50){
    ggplot(jobSummaries, aes(reorder(jobid, -as.numeric(jobid)), exec_time_hours)) + geom_bar(stat="identity") + ggtitle("job execution times") + coord_flip() + xlab("job id")
}else{
    ggplot(jobSummaries, aes(as.numeric(jobid), exec_time_hours))  + geom_area() + ggtitle("job execution times")+ xlab("job_nr") + geom_hline(mapping=aes(yintercept=queueLimit), color="red")
}

#ggplot(jobSummaries, aes(as.numeric(jobidx), exec_time_min/pending_time_min)) + geom_area() + ggtitle("pending vs exec time ratio")+xlab("job_nr")
ggplot(jobSummaries, aes(exec_time_min, pending_time_min)) + geom_point() + ggtitle("pending vs exec time") + geom_abline()

jobSummaries %<>% mutate(exceeded_queue_limit=exec_time_hours>queueLimit)

write.delim(jobSummaries, file=paste0(reportName, ".jobSummaries.txt"))
# jobSummaries <- read.delim("jobSummaries.txt")

require_auit(knitr)
jobSummaries %>% mutate(pending_time_hours=pending_time_min/60) %>% select(jobid, exec_host, job_name, cpu_used_hours, pending_time_hours, exec_time_hours) %>% kable()


#######################################################################################################################
## create warning email if jobs died
## todo finish send mail if wall time was exceeded


numKilled=nrow(filter(jobSummaries, exceeded_queue_limit))
numTotal= nrow(jobSummaries)

killedListFile=paste0(reportName, ".killed_jobs.txt")
if(numKilled >0){
    system(paste("mailme '",numKilled,"out of ",numTotal," jobs in ", getwd(), " died because of queue length limitation'"))
    filter(jobSummaries, exceeded_queue_limit) %$% writeLines(jobid, con=killedListFile)
}else{
    ## Create an empty killed list to indicate that we actually looked into it
    file.create(killedListFile)
}

