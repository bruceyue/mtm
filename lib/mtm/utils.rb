require 'twilio-ruby'

module Mtm
  extend self

  # for date format argv
  def parse_days_or_date(d)
      if d.to_s =~ /^\d+$/
      d.to_i
    else
      Date.parse(d)
    end
  end

  # Creates time card
  def create_timecard(*args, client)
    client.create!('TimeCard__c', Project__c: args[0],
                                 Change__c: args[1],
                                 Date__c: args[2],
                                 Hours__c: args[3],
                                 TeamMember__c: args[4],
                                 Description__c: args[5])
    puts
    puts "Timecrad created successfully. Hour: '#{args[3]}', Project: '#{args[6]}'"
  end

  def send_sms(mobile, *args)
    # twilio
    account_sid = 'ACe81d15486c1f4568a9c981053bce307b'
    auth_token = 'a502db99e86340c4967cb89f0714c4ce'

    if !mobile.empty?
      # set up a client to talk to the Twilio REST API
      @t_client = Twilio::REST::Client.new account_sid, auth_token
      @t_client.account.sms.messages.create(
        :from => '+19788000322',
        :to => '+86' + mobile,
        :body => "Project: #{args[0]}, Hours: #{args[1]}, Description: #{args[2]}"
      )
    end
  end

end