# GroupWise Scripts
GroupWise Admin Helpdesk Scripts by Cimitra
Version: 1.4
Author: Tay Kratzer tay@cimitra.com
License: Free for whatever you would like!
Testing Info: These scripts have been tested on **SLES12 and GroupWise 18**

**Installation is just 4 easy steps!**

**1.** *Download* the GroupWise Admin Helpdesk Scripts by Cimitra **install** script file to a GroupWise server on Linux

**2.** *Change* the **install** script file to be *executable* on the Linux box: chmod +x ./install

**3.** *Run* the **install** script file, consider using the "help" directive to get help: ./install help

UNIVERSAL SETTINGS FILE (settings_gw.cfg)
All of these scripts are designed to read configuration settings from the settings_gw.cfg file. The settings_gw.cfg file should be automatically generated if it does not exist. When you run a script, with the properly configured command line variables, if the settings_gw.cfg file does not exist, the script will create it. If you will are having troubles getting a settings_gw.cfg file just run the script: gw_system_list_users.sh and the file should get automatically created. 

UNIVERSAL HELP
To get the help for a script, just run the script, or run it with a -h script and you will get a help screen. 

**4.** *CONFIGURE* GWADMIN-SERVICE LOCATION AND CREDENTIALS

Edit the settings_gw.cfg file and make sure GW_ADMIN* variables are properly configured. Similar to this. 

GW_ADMIN_SERVICE_ADDRESS="192.168.1.2"

GW_ADMIN_SERVICE_PORT="9710"

GW_ADMIN_USER="Cimitra"

GW_ADMIN_PASSWORD="isCool"

**A** EXCLUDE GROUPS ( A really cool feature, read on my friends! )
All scripts that modify or read user objects have a built in "exclude" function. Namely, you can make it so that certain users are excluded from being affected or viewed with these scripts. You can either user the exclude_gw.cfg file or an "exclude group" in GroupWise. 

STEP **1.** TO MAKE AND "EXCLUDE GROUP"
Make a new group in GroupWise, give it a name of your choosing.

STEP **2.** ADD USERS TO THE "EXCLUDE GROUP"
Add users to that group that you do not want the scripts to be able to modify or view etc. So for example, if you were to share these scripts with Help Desk personnel via Cimitra, but you wanted to make sure that the Help Desk personnel couldn't modify your account, and other admins etc. then you would add yourself and others to that the group you made for handling exclusions. 

STEP **3.** MODIFY THE settings_gw.cfg FILE
Edit the settings_gw.cfg file and define the following fields specific to the exclude group you created. If I called the GroupWise Group HELP_DESK_CANNOT_ADMINISTER then my settings_gw.cfg file would look something like this: 

GW_EXCLUDE_GROUP_ENABLED="1"

GW_EXCLUDE_GROUP_NAME="HELP_DESK_CANNOT_ADMINISTER"

GW_EXCLUDE_GROUP_POST_OFFICE_NAME="PO1"

GW_EXCLUDE_GROUP_DOMAIN_NAME="DOMAIN1"

USER QUICKFINDER INDEX REBUILD SCRIPT
One of the scripts, gw_user_quickfinder.sh can rebuild a user's QuickFinder index files. This script needs information about the POA's HTTP console. Run the script with the appropriate input information and it will make additional changes to the settings_gw.cfg file for you to configure. 
