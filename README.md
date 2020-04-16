GroupWise Admin Helpdesk Scripts by Cimitra
Version: 1.5

Author: Tay Kratzer tay@cimitra.com

Special thanks to Eliot Lloyd Lanes and Viable Solutions Inc. for hosting the GroupWise and eDirectory systems where we I created these scripts. ​

Testing Info: These scripts have been tested on **SLES12 and GroupWise 18**

Documentation and introduction at https://cimitra.com/gw

**Installation and Configuration is just 2 easy steps!**

**1.** **DOWNLOAD AND RUN** the GroupWise Admin Helpdesk Scripts by Cimitra **install** script file on a GroupWise server on Linux

**curl -LJO https://raw.githubusercontent.com/cimitrasoftware/groupwise/master/install -o ./ ; chmod +x ./install ; ./install**

**2.** **CONFIGURE** EXCLUDE_GROUP in the **THE SETTINGS FILE (settings_gw.cfg)**

The (settings_gw.cfg) is in the following directory:

**/var/opt/cimitra/scripts/grouwpise-master/helpdesk/settings_gw.cfg**

**EXCLUDE GROUPS** ( A really cool feature, read on my friends! )
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

**USER QUICKFINDER INDEX REBUILD SCRIPT**
One of the scripts, gw_user_quickfinder.sh can rebuild a user's QuickFinder index files. This script needs information about the POA's HTTP console. Run the script with the appropriate input information and it will make additional changes to the settings_gw.cfg file for you to configure. 

**EDIRECTORY INTEGRATION**
For scenarios in which editing of a user's First Name, Last Name, and Phone Number and Password are only available via eDirectory integration through tools such as iManager, there are some scripts that require eDirectory credentials. These scripts require that the settings_gw.cfg file settings below are properly configured: 
  
GW_EDIR_ADMIN_USER

GW_EDIR_ADMIN_PASSWORD

GW_EDIR_LDAP_SERVICE_SIMPLE_AUTHENTICATION_ADDRESS

GW_EDIR_LDAP_SERVICE_SIMPLE_AUTHENTICATION_PORT

**UPGRADING/UPDATING**
The GroupWise Admin Helpdesk Scripts by Cimitra ships with a script specifically for upgrading to the latest version of these scripts. The update script will be in the directory where you installed the software in the "groupwise-master" directory. For most installations this will be: **/var/opt/cimitra/scripts/groupwise-master** 

The script is simply called: **update**

**Enjoy**

*Tay Kratzer*

tay@cimitra.com
