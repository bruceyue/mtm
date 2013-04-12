$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))
%w(sfdc optparse/date ruby-progressbar utils config version).each do |file|
  require "#{file}"
end

# Parse arguments
options = {}
options[:user_name] = SF_USERNAME
options[:password] = SF_PASSWORD
options[:security_token] = SF_SECURITY_TOKEN
options[:test] = false
options[:host] = 'login.salesforce.com'
options[:tm_list] = false
options[:tm_project] = SF_PROJECT
options[:tm_p_number] = SF_PROJECT_NUMBER
options[:tm_change] = SF_CHANGE
options[:tm_c_number] = SF_CHANGE_NUMBER
options[:tm_hour] = SF_HOUR
options[:tm_date] = DateTime.now.to_date
options[:tm_description] = SF_TIMECARD_DESCRIPTION
options[:feeds] = false

# salesforce remote app client id
sf_client_id = '3MVG9Y6d_Btp4xp6SWO6yPlUURnycVbOfuH7I_NH2bjaw0yeoguRatNzKRpEVaIvmX7TcQbVVjuQUCZ006pwN'
sf_client_secret = '5339957415407001741' # salesforce remote app client secret
user_name_suffix = '@pm.meginfo.com'

op = OptionParser.new do |opts|
  opts.banner = <<-BANNER
    Timecard Solution
    Usage: run 'gem environment' in your console and find the 'GEM PATHS'
           go to 'GEM PATHS/gems/mtm-3.0.0/lib/mtm'
           open config.rb and input your Salesforce user name and password(token).
           mtm -p project -c change -t 6 -e 'Added exception process logic.'
  BANNER
  opts.separator ''

  opts.on("-u", "--user username:password", "The user name and password.") do |u|
    options[:up] = u
    options[:user_name] = options[:up].split(':').first << user_name_suffix
    options[:password] = options[:up].split(':').last
  end

  opts.on("-T", "--token token", "The password security token.") do |token|
    options[:security_token] = token
  end

  opts.on("-s", "Change to sandbox environment.") do |test|
    options[:test] = test
    options[:host] = 'test.salesforce.com'
  end

  opts.on("-l", "List all your not closed projects and changes.") do |list|
    options[:tm_list] = list
  end

  opts.on("-L ProjectPartName", "List some specific projects and changes.") do |l|
    options[:tm_s_list] = l
  end

  opts.on("-p ProjectName", "The project full Name or part name.") do |project|
    options[:tm_project] = project
  end

  opts.on("-N ProjectNumber", "The project number: 07865(Prj-07865).") do |number_p|
    options[:tm_p_number] = number_p
  end

  opts.on("-c ChangeName", String, "Full change name or part.") do |c|
    options[:tm_change] = c
  end

  opts.on("-n ChangeNumber", "The change number.") do |number_c|
    options[:tm_c_number] = number_c
  end

  opts.on("-t Hours", Float, "Total hours of todays work.") do |h|
    options[:tm_hour] = h
  end

  opts.on("-d", "--date YYYY-MM-DD", "Timecard Date, default: TODAY", "Enter date in (YYYY-MM-DD) format.") do |d|
    options[:tm_date] = Mtm.parse_days_or_date(d)
  end

  opts.on("-e Description", "Timecard detail information, describle today's work.") do |desc|
    options[:tm_description] = desc
  end

  opts.on("-f", "List your Chatter feeds") do |f|
    options[:feeds] = f
  end

  opts.on_tail("-h", "--help", "Show help message") do
    puts op
    exit
  end

  opts.on_tail("-v", "Show version") do
    puts Mtm::VERSION
    exit
  end
end

begin
  op.parse(ARGV)
rescue Exception => e
  abort e.message
end

if ARGV.size < 1
  puts op
  exit
end

@pb = ProgressBar.create(title: 'Logging', starting_at: 0, total: 100, progress_mark: '*', format: '%w %%')
40.times { sleep(0.05); @pb.increment }

# login to salesforce.com
begin
  client = Sfdc.new :client_id => sf_client_id,
                          :client_secret => sf_client_secret,
                          :username => options[:user_name],
                          :password => options[:password],
                          :security_token => options[:security_token],
                          :host => options[:host]
  response = client.authenticate!
  info = client.get(response.id).body
  @sf_user_id = info.user_id
rescue Exception => e
  puts
  puts e.message
  abort 'Failed to connect to Salesforce.'
end

# List your Chatter feeds
if options[:feeds]
  puts
  client.feeds.each do |f|
    puts f.to_hash['actor']['name'] << ': '
    puts '      '<< f.to_hash['body']['text']
    puts
  end
  @pb.finish
  abort
end

# list all projects and its changes
if options[:tm_list]
  40.times { sleep(0.05); @pb.increment }
  projects = client.query("select Id, Name, ProjectNumber__c, (select Id, Name, ChangeNumber__c from Changes__r
                                    where Status__c != 'Closed') from MProject__c where Status__c != 'Closed'")
  projects.each do |p|
    puts
    puts p.ProjectNumber__c + ': ' + p.Name
    if p.Changes__r != nil
      p.Changes__r.each do |c|
        puts '     '+ c.ChangeNumber__c + ': ' + c.Name
      end
    end
  end
  @pb.finish
  abort
end

# list some projects and its changes
if options[:tm_s_list] != nil
  40.times { sleep(0.05); @pb.increment }
  projects = client.query("select Id, Name, ProjectNumber__c, (select Id, Name, ChangeNumber__c from Changes__r
                                    where Status__c != 'Closed') from MProject__c where Status__c != 'Closed' and Name like '%#{options[:tm_s_list]}%'")
  if projects.size == 0
    puts
    abort 'No project found'
  end
  projects.each do |p|
    puts
    puts p.ProjectNumber__c + ': ' + p.Name
    if p.Changes__r != nil
      p.Changes__r.each do |c|
        puts '     '+ c.ChangeNumber__c + ': ' + c.Name
      end
    end
  end
  @pb.finish
  abort
end

msg = 'Project not found'
begin
  if options[:tm_project] != ''
    projects = client.query("select Id, Name, (select Id, Name from Changes__r where Status__c != 'Closed' and
                            Name like '%#{options[:tm_change]}%') from MProject__c where Status__c != 'Closed'
                            and Name like '%#{options[:tm_project]}%'")
  elsif options[:tm_p_number] != nil
    p_number = 'Prj-' << options[:tm_p_number]
    projects = client.query("select Id, Name, (select Id, Name from Changes__r where Status__c != 'Closed'
                              and ChangeNumber__c = '#{options[:tm_c_number]}')
                              from MProject__c where Status__c != 'Closed' and ProjectNumber__c = '#{p_number}'")
  end
  30.times { sleep(0.05); @pb.increment }
rescue Exception => e
  puts
  puts e.message
  abort msg
end

if options[:tm_project] == '' &&  options[:tm_p_number] == nil
  puts
  abort "You must enter -p ProjectName or -N ProjectNumber to specify a project."
end

if projects.first == nil
  puts
  abort msg
end

is_success = true
if projects.size == 1
  begin
    team_member = client.query("select Id from TeamMember__c where Project__c = '#{projects.first.Id}' and User__c = '#{@sf_user_id}'");
    if(options[:tm_change] == '' && options[:tm_c_number] == nil)
      Mtm.create_timecard(projects.first.Id, nil, options[:tm_date], options[:tm_hour],
                      team_member.first.Id, options[:tm_description], projects.first.Name, client)
    else
      if (projects.first.Changes__r != nil && projects.first.Changes__r.size == 1)
        Mtm.create_timecard(projects.first.Id, projects.first.Changes__r.first.Id,
                        options[:tm_date], options[:tm_hour], team_member.first.Id,
                        options[:tm_description], projects.first.Name, client)
      elsif projects.first.Changes__r == nil
        is_success = false
        puts
        puts 'No change found.'
      else
        is_success = false
        puts
        puts 'Please select a change to continue:'
        projects.first.Changes__r.each { |c| puts c.Name }
      end
    end
  rescue Exception => e
    is_success = false
    puts
    puts e.message
    abort 'Failed to create timecard.'
  end
else
  is_success = false
  puts
  puts 'Please select a project to continue:'
  projects.each { |p| puts p.Name }
end

if is_success
  begin
    Mtm.send_sms(MOBILE_NUMBER, projects.first.Name, options[:tm_hour], options[:tm_description])
  rescue Exception => e
    puts
    puts e.message
    abort 'Failed to send SMS to your mobile, please contact www.sharealltech.com to verify it!'
  end
end

@pb.finish
