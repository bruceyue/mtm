## Mtm

Timecard solution for a day's work information

## Installation

the default environment is ruby 1.9.3
Opens your teminal and input:
   `gem install mtm`

## Usage
* Opens your teminal and input:
  `mtm -p 'Project name' -c 'Change name' -t 8 -e 'Tested some pages' -u bruce.yue:password`
* The default hours is 8 and default description is "Tested some pages and fixed some bugs."
* If step 2 have been done, '-u' is not required in the step 3.
For example:
   * Project "CM Peak Development Requests", Its change is "Automate Upload of Build Records"
   `mtm -p 'Peak Development' -c 'Build Records' -t 6 -e 'Added exception process logic.'`

* If there is no change. just paste

  `mtm -p 'Peak Development' -t 6 -e 'Added exception process logic.'`

* Fill your time card at some time.
  `at 9pm today mtm -p 'Peak Development' -t 6 -e 'Added exception process logic.'`


## Config

1. run
     `gem environment`
   Find the GEM PATHS
2. go to
    'GEM PATHS'/gems/mtm-2.0.4/lib/mtm'
3. config
    open config.rb
    config field
    SF_USERNAME = ''  # Salesforce user name
    SF_PASSWORD = '' # Salesforce password
    SF_SECURITY_TOKEN = '' # Salesforce password security token(option)
    MOBILE_NUMBER = '' # 18988888888 you need to send the mobile to me and verify it.
4. `mtm -h` for details