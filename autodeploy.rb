#!/usr/bin/env ruby
require 'optparse'

ARGV << '-h' if ARGV.empty?

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: autodeploy.rb [options]"

  opts.on("-d netid", "--dev netid", "Developer netid") do |n|
     options[:netid] = n
  end

  opts.on("-u url", "--git-url url", "SSH Git repo URL for application") do |n|
    if /^git@/.match(n) 
       options[:url] = n
    else 
       print "\n\nERROR: You must provide a GitHub SSH URL in the format git@github.com:ndoit/repo_name.git \n\n"
       exit
    end
  end

  opts.on("-e env", "--cap-environment env", "The name of the capistrano environment file to use") do |n|
    options[:env] = n
  end

  opts.on("-s remote_user", "--remote-user remote_user", "The name of the remote user") do |n|
    options[:remote_user] = n
  end

  opts.on("-p remote_password", "--remote-password remote_password", "The password of the remote user") do |n|
    options[:remote_password] = n
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
end.parse!

p options

temp_dir = "deploy_me"

cmds = [] 
cmds << "git clone #{options[:url]} #{temp_dir}"
cmds << "cd #{temp_dir}"
cmds << "bundle install" 
cmds << "bundle exec cap #{options[:env]} deploy:first_time"
cmds << "rm -rf #{temp_dir}"
all_cmds = cmds.join(' && ')
output = `#{all_cmds}` 

# what about when cap deploys to multiple machines?
