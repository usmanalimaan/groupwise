GroupWise Admin Helpdesk Scripts by Cimitra
Version: 1.0
Date 6/3/2020

Author: Tay Kratzer tay@cimitra.com

Special thanks to Eliot Lloyd Lanes and Viable Solutions Inc. for hosting the GroupWise and eDirectory systems where we created these scripts. 

Testing Info: These scripts have been tested on **SLES12 and GroupWise 18**

Documentation and introduction at https://cimitra.com/gw

**Installation and Configuration is just 3 easy steps!**

**1.** **On a SUSE Box where you have installed a Cimitra Agent type in the following command**

**cimitra get gw**

**2.** **Run the GroupWise Integration Setup Utility** 

**cimitra gw**

**3.** **Configure an Exclude Group**

**Exclude Group** ( A really cool feature, read on! )

All scripts that modify or read user objects have a built in "exclude" function. Namely, you can make it so that certain users are excluded from being affected or viewed with these scripts. This way if you want a user, or users that cannot be modified by GroupWise Domain and Post Office admins, you can exclude those users from being modified. 

STEP **1.** TO MAKE AND "EXCLUDE GROUP"
Make a new group in GroupWise, give it a name of your choosing. Don't have any spaces in the group name. Something like CIMITRA_EXCLUDE might be good. 

STEP **2.** ADD USERS TO THE "EXCLUDE GROUP"
Add users to that group that you do not want the scripts to be able to modify or view etc. So for example, if you were to share these scripts with Help Desk personnel via Cimitra, but you wanted to make sure that the Help Desk personnel couldn't modify your account, and other admins etc. then you would add yourself and others to that the group you made for handling exclusions. 

STEP **3.** DEFINE THE EXCLUDE GROUP IN THE CIMITRA GROUPWISE INTEGRATION SETUP UTILITY

**Command: cimitra gw**

**USER QUICKFINDER INDEX REBUILD SCRIPT**
One of the scripts, gw_user_quickfinder.sh can rebuild a user's QuickFinder index files. This script needs information about the POA's HTTP console. Run the script with the appropriate input information and it will make additional changes to the settings_gw.cfg file for you to configure. 

**EDIRECTORY INTEGRATION**
For scenarios in which editing of a user's First Name, Last Name, and Phone Number and Password are only available via eDirectory integration through tools such as iManager, there are some scripts that require eDirectory credentials. These scripts require eDirectory credentials be configured. When you run the Cimitra GroupWise Integration Setup Utility the eDirectory settings are configured under the Configure GroupWise Admin Credentials menu option.  

**UPGRADING/UPDATING**
The GroupWise Admin Helpdesk Scripts by Cimitra ships with a script specifically for upgrading to the latest version of these scripts. To invoke the script isse the following: 

**cimitra gw update**

**Enjoy**

*Tay Kratzer*

tay@cimitra.com
