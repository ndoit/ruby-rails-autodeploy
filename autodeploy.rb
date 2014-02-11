#!/usr/bin/env ruby
require 'optparse'
require 'erb'

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

#  opts.on("-e env", "--cap-environment env", "The name of the capistrano environment file to use") do |n|
#    options[:env] = n
#  end

  opts.on("-r remote_host", "--remote-host remote_host", "The target machine") do |n|
    options[:remote_host] = n
  end

  opts.on("-s remote_user", "--remote-user remote_user", "The name of the remote user") do |n|
    options[:remote_user] = n
  end

  opts.on("-p remote_password", "--remote-password remote_password", "The password of the remote user") do |n|
    options[:remote_pass] = n
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

end.parse!

p options

# simple capistrano environment template
# what about when cap deploys to multiple machines?
# we could just instruct the ops user to edit the passwords in...
deploy_env_template = %{ 

  server '<%= remote_host %>', user: '<%= remote_user %>', password: '<%= remote_pass %>', roles: %w{web app} 

}

temp_dir = "deploy_me"
temp_env = "deploy_env"

# render out a capistrano deploy template
remote_host = options[:remote_host]
remote_user = options[:remote_user]
remote_pass = options[:remote_pass]
renderer = ERB.new(deploy_env_template)
puts rendered_env = renderer.result()

output = `git clone #{options[:url]} #{temp_dir}`
env_file = "#{temp_dir}/config/deploy/#{temp_env}.rb" 
File.open(env_file,'w') do |s|
    s.puts rendered_env 
end

cmds = [] 
cmds << "cd #{temp_dir}"
cmds << "bundle install" 
cmds << "bundle exec cap #{temp_env} deploy:first_time"
cmds << "rm -rf #{temp_dir}"
all_cmds = cmds.join(' && ')
output = `#{all_cmds}` 

