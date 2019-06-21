con<-file("analysis.log")
sink(con, append=TRUE)
sink(con, append=TRUE, type="message")


#set pandoc
Sys.setenv(RSTUDIO_PANDOC="/usr/local/bin/")

################################################################################################################
################################################################################################################

Sys.setenv(TZ='GMT')



################################################################################################################
#get data from Archiver
################################################################################################################
{
  rm(list=ls())
  unlink("Output/",recursive = T)
  system("cp -rf /INSERT_PATH_HERE/Archiver/Data/Output/  ./Output")
  unlink("report/",recursive = T)
  unlink("*.zip")
}


################################################################################################################
# USER MODIFIABLE SETTINGS
################################################################################################################


#directories
export.dir.name <- paste(getwd(),"Output",sep="/")
report.dir.name <- paste(getwd(),"report",sep="/")
storage.dir.name <- paste(getwd(),"xmls",sep="/")



#DO STUFF HERE




zipr(zipfile=paste("REPORTS_",format(Sys.time(), "%y%m%d.%H%M"),".zip",sep=""),files=report.dir.name)

timestamp()

message("writing workspace")
save.image(compress = "gzip",safe = TRUE,file = "Workspace.Rdata")

beepr::beep()

sink()
sink(type="message")
