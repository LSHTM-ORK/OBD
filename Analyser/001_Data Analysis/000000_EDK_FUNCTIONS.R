################################################################################################################
####ODK Briefcase Call Function
################################################################################################################

#function to pull data from ODK Aggregate Server
################################################################################################################



odk.briefcase.pull<-
  function(
    aggregate.url=NULL,            #arg  -url   <url>
    odk.directory=NULL,           #arg         <path/to/dir>
    odk.username="admin",         #arg  -u     <username>
    form.id=NULL,                 #arg  -id    <form_id>
    export.dir=".",               #arg  -ed    <path/to/dir>
    storage.dir=".",              #arg  -sd    <path/to/dir>
    export.start.date=NULL,       #arg  -start <yyyy/MM/dd>
    export.end.date=NULL,         #arg -end   <yyyy/MM/dd>
    pem_file=NULL,                #arg -pf    <path/to/file.pem>
    exclude.media.export=FALSE,   #flag -em
    overwrite.csv.export=TRUE,   #flag -oc
    update.odk.briefcase=FALSE
  ){
    
    
    
    ################################################################################################################
    # Purge CSVs and delete XMLS if needed
    ############################################################################################################    
    
    if(deletexmlpre==T){
      unlink(x = storage.dir,recursive = T)
    }
    if(purge==TRUE)
    {
      unlink(x = export.dir.name,recursive = T)
    }
    
    
    
    
    ################################################################################################################
    # INSTALL REQUIRED PACKAGES    
    ############################################################################################################    
    message("installing packages if needed")
    #check if getPass is installed and install it if not
    message("checking for new packages")
    list.of.packages <- c("getPass","anytime","tidyverse","plotKML","sp","rgdal","lubridate","leaftlet")
    
    new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
    if(length(new.packages))
    {
      install.packages(new.packages)
      message (paste("Installing ",new.packages))
    }
    
    
    
    
    ################################################################################################################
    #check if update.odk.briefcase flag was active (default) and update odk briefcase
    ################################################################################################################
    message("Checking to see if Briefcase should be updated.")
    if(update.odk.briefcase==T)
      
    {
      message("Updating ODK Briefcase")
      #download.file(url = "https://github.com/opendatakit/briefcase/releases/download/v1.10.1/ODK-Briefcase-v1.10.1.jar",
      #             destfile = paste( "./odkbriefcase.jar",sep = ""), method="curl", mode = "wb",extra="-L")
      system("curl -L  https://github.com/opendatakit/briefcase/releases/download/v1.10.1/ODK-Briefcase-v1.10.1.jar > ./odkbriefcase.jar")
    }
    
    
    
    ################################################################################################################    
    #check that only online or offline is being used
    ############################################################################################################
    if (!is.null(aggregate.url) & !is.null(odk.directory))
    {
      message("Please only specify one of aggregate.url and odk.directory")
    }
    
    
    
    
    ################################################################################################################    
    #add flags for command line call
    ###############################################################################################################
    if(!is.null(aggregate.url)){aggregate.url<-paste("-url ", aggregate.url, sep="")}            #arg  -url   <url>
    if(!is.null(odk.directory)){odk.directory<-paste("-od ", odk.directory, sep="")}
    odk.username<-paste("-u ", odk.username, sep="")
    export.dir<-paste("-ed ", export.dir, sep="")
    storage.dir<-paste("-sd ", storage.dir, sep="")
    if(!is.null(export.start.date)){export.start.date<-paste("-start ", export.start.date, sep="")}
    if(!is.null(export.end.date)){export.end.date<-paste("-end ", export.end.date, sep="")}
    if(!is.null(pem_file)){pem_file<-paste("-pf ", pem_file, sep="")}
    if(exclude.media.export==T){exclude.media.export<-"-em"}else{exclude.media.export<-""}
    if(overwrite.csv.export==T){overwrite.csv.export<-"-oc"}else{overwrite.csv.export<-""}
    
    ################################################################################################################
    #Get Password for current user
    ################################################################################################################    
    
    password<- getPass(msg = "Enter Password for server")
    password<- paste("-p ",password,sep="")
    
    
    ################################################################################################################
    #Generate command for system call to odk briefcase for each form in form.id
    ################################################################################################################    
    
    for(p in form.id)
    {
      
      export.filename<-paste(p,"_",Sys.Date(),".csv",sep="")
      if(!is.null(export.filename)){export.filename<-paste("-f ", export.filename, sep="")}
      form.id2<-paste("-id ", p, sep="")
      
      command<-paste("java -jar odkbriefcase.jar ",
                     aggregate.url,
                     odk.directory,
                     odk.username,
                     form.id2,
                     export.dir,
                     export.start.date,
                     export.end.date,
                     export.filename,
                     storage.dir,
                     pem_file,
                     exclude.media.export,
                     overwrite.csv.export,
                     password,
                     sep=" ")
      
      system(command)
    }
    if(autodelete==TRUE){
      unlink(x = export.dir.name,recursive = T)
    }
    
    ####deleteXMLS
    if(deletexmlpost==TRUE){
      unlink(x = "XMLS",recursive = T)
    }
  }

################################################################################################################    
################################################################################################################    
# END OF FUNCTION
################################################################################################################    
################################################################################################################




################################################################################################################
#### Function to count instances and get most recent date
################################################################################################################

summarise.csv<-function(file)
{
  a<-read.csv(file = file)
  rows<-dim(a)[1]
  if(rows==0){result<-list(file,rows,as.Date(NA),as.Date(NA))}
  if(rows>0 && !is.null(a$SubmissionDate))
  {
    a$SubmissionDate<-convert.odk.dates(a$SubmissionDate)
    mostrecent<-max(a$SubmissionDate)
    a$today<-convert.odk.dates(a$today)
    mostrecent_new_data<-max(a$today)
    result<-list(file,rows,mostrecent,mostrecent_new_data)
  }

  if(rows>0 && is.null(a$SubmissionDate))
  {
    result<-list(file,NA,as.Date(NA),as.Date(NA))
  }
return(result)
  }
##################################################################################
#### END OF FUNCTION
##################################################################################




##################################################################################
#### Convert ODK formatted dates to standard POSIX (works for both 'today' and 'start'/'end')
##################################################################################

#convert.odk.dates<-function(dates) [old]
#{
#  dates<-gsub(pattern = " ",replacement = "-",x = dates)
#  dates<-gsub(pattern = ",-",replacement = " ",x = dates)
#  dates<-anytime::anytime(dates)+lubridate::hours(2)
#}

convert.odk.dates<-function(dates)
{

  
  #convert dates in format "6 Aug 2018"
  if (grep(x = dates[1],pattern = "\\d \\w{3} \\d{4}")==1)
  {
dates<-strptime(dates,format = "%d %b %Y")
dates<-as.Date(dates,format="%Y-%m-%d")
return(dates)
  }
  
  #convert dates in format "6 Aug 2018, 19:44:38"
  if (grep(x = dates[2],pattern = "\\d \\w{3} \\d{4}, \\d{2}:\\d{2}:\\d{2}")==1)
  {
    dates<-strptime(dates,format = "%d %b %Y, %H:%M:%S")
    dates<-as.Date(dates,format="%Y-%m-%d")
  return(dates)
  }
  
  
}


################################################################################################################
# Check libraries
################################################################################################################
message("installing packages if needed")
message("checking for new packages")
list.of.packages <- c("getPass","anytime","tidyverse","plotKML","sp","rgdal","lubridate","fuzzyjoin")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages))
{
  install.packages(new.packages)
  message (paste("Installing ",new.packages))
}






################################################################################################################
# Get OS type
################################################################################################################

get_os <- function(){
  sysinf <- Sys.info()
  if (!is.null(sysinf)){
    os <- sysinf['sysname']
    if (os == 'Darwin')
      os <- "osx"
  } else { ## mystery machine
    os <- .Platform$OS.type
    if (grepl("^darwin", R.version$os))
      os <- "osx"
    if (grepl("linux-gnu", R.version$os))
      os <- "linux"
    if (grepl("windows", R.version$os))
      os <- "windows"
  }
  tolower(os)
}


################################################################################################################
# Get user name
################################################################################################################

get_os <- function(){
  sysinf <- Sys.info()
  if (!is.null(sysinf)){
    os <- sysinf['sysname']
    if (os == 'Darwin')
      os <- "osx"
  } else { ## mystery machine
    os <- .Platform$OS.type
    if (grepl("^darwin", R.version$os))
      os <- "osx"
    if (grepl("linux-gnu", R.version$os))
      os <- "linux"
    if (grepl("windows", R.version$os))
      os <- "windows"
  }
  tolower(os)
}


message("Functions loaded")