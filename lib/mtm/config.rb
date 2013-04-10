####################################################################################
############################### start parse value ##################################
####################################################################################
# please fill these fields:                                                      ###
SF_USERNAME = ''  # Salesforce user name                                         ###
SF_PASSWORD = '' # Salesforce password                                           ###
SF_SECURITY_TOKEN = '' # Salesforce password security token(option)              ###
MOBILE_NUMBER = '' # 18988888888 you need to send the mobile to me and verify it.


############ option ################
SF_PROJECT = '' # project name
SF_PROJECT_NUMBER = nil # project number #if Prj-07867, SF_PROJECT_NUMBER = 07867 
SF_CHANGE = '' # change name
SF_CHANGE_NUMBER = nil # change number
SF_HOUR = 8   # time card hours
SF_TIMECARD_DESCRIPTION = 'Tested some pages and fixed some bugs.'
####################################################################################
############################## end parse value #####################################
####################################################################################

=begin
  How to use this script?
  1. Opens your teminal and input:$: gem install mtm
  2. Opens this file and paste your user name, password and sf_security_token.
  3. Opens your teminal and input: tm -p 'Project name' -c 'Change name' -h 8 -d 'Tested some pages' -u bruce.yue:password
     The default hours is 8 and default description is "Tested some pages and fixed some bugs."
     If step 2 have been done, '-u' is not required in the step 3.
     For example:
     Project "Silver Peak Development Requests", Its change is "Automate Upload of Build Records"
     $: tm -p 'Peak Development' -c 'Build Records' -h 6 -d 'Added exception process logic.'

    If there is no change. just paste
    $: tm -p 'Peak Development' -h 6 -d 'Added exception process logic.'

    Fill your time card at some time.
    $: at 9pm today tm -p 'Peak Development' -h 6 -d 'Added exception process logic.'
=end