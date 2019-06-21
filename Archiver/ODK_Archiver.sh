#!/usr/bin/env bash

#########################################################################################
## USER DEFINED VARIABLES
#########################################################################################
ODK_STORAGE_PATH="Data"
ODK_EXPORT_PATH="Data/Output"
URL="https://serverURL/submission_dir/"
ODKUSERNAME="admin"
PEM="keys/NAME.pem"

#########################################################################################
#########################################################################################

# GET TODAY'S DATE
PULLTIME=$(date +"%Y-%m-%d")
PULLTIME2=$(date +"%Y-%m-%d_%H_%M_%S")

echo Today is "$PULLTIME"
# GET YESTERDAY'S DATE
EXPORTLIMIT=$(date -v -1d +"%Y-%m-%d")

echo Today is "$PULLTIME"


## Get the password from file "pass"
source serverpass.txt

declare -a arr=(
#########################################################################################
## ADD ODK FORM IDs BELOW THIS LINE  (FORMID;FORMNAME) replace and . with _
#########################################################################################
"TEST_1001;PARTICIPANTS"
"TEST_1002;LAB_DATA"
"TEST_1003;ENVIRONMENT_DATA"
#########################################################################################
#########################################################################################
                )





## now loop through the above array and perform functions on every form ID
for i in "${arr[@]}"
	do
		j="output/$i.csv"
		#until ( test -e "$j"); 
		#do
			echo Working on form "$j" 				
			FORM_ID=$(echo "$i" | cut -d ";" -f1)
			FORM_NAME=$(echo "$i" | cut -d ";" -f2)
			echo Form Name : "$FORM_NAME"
			echo Form ID :  "$FORM_ID"
			echo getting "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/nextpull.txt
			echo Date of next pull "$NEXTPULL"
			#read in the next pull date from nextpull.txt
			if [ ! -f "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/nextpull.txt ]; then
			    echo "Next pull not found! Creating 1970-01-01"
				echo NEXTPULL=1970-01-01 | cat > "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/nextpull.txt
			fi
			source "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/nextpull.txt
				
			#make folders for archive
			mkdir "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/
			mkdir "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/archive/
			mkdir "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/archive/"$PULLTIME2"
		
			#pull data using briefcase -sfd option and $NEXTPULL
			echo Pulling data from "$NEXTPULL" onwards
			java -jar ODK-Briefcase-v1.15.0.jar -sfd "$NEXTPULL" -plla -pp -id "$FORM_ID" -sd "$ODK_STORAGE_PATH" -url $URL -u "$ODKUSERNAME" -p "$ODKPASSWORD"
		
			#export data from form using -start $NEXTPULL and -end $EXPORTLIMIT (i.e. start at last day when pull was done and end at yesterday)
			echo exporting new instances since "$NEXTPULL" and up to "$EXPORTLIMIT"
			java -jar ODK-Briefcase-v1.15.0.jar -e -ed "$ODK_EXPORT_PATH"/ -start "$NEXTPULL" -end "$EXPORTLIMIT" -sd "$ODK_STORAGE_PATH" -id "$FORM_ID" -f "$FORM_ID".csv -pf "$PEM"
		
			#move anything pulled today to a timestamped folder
			echo moving instances to archive
			find "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/instances/ -name '*' -exec mv -f \{\} "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/archive/"$PULLTIME2"/ \;

			#write today's date to the nextpull.txt file. The next pull will resume at today's date
			echo writing next pulltime to nextpull.txt
			echo NEXTPULL="$PULLTIME" | cat > "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/nextpull.txt
			mkdir "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/instances
			#make a backup of the CSV file
			echo making backup copy of CSV file
			cp "$ODK_EXPORT_PATH"/"$FORM_ID".csv "$ODK_STORAGE_PATH"/ODK\ Briefcase\ Storage/forms/"$FORM_NAME"/archive/"$PULLTIME2"/"$PULLTIME2".csv
	done

date +"%Y_%m_%d_%H_%M" >  "$ODK_EXPORT_PATH"/000_timestamp.txt


 
