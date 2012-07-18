require 'resque'
require 'redis'

root = "/home/deployer/apps/givingtree/current"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "/tmp/unicorn.givingtree.sock"
worker_processes 2
timeout 30

after_fork do |server, worker|
  Resque.redis = Redis.new(:host => 'localhost', :port => 6379)
end

before_fork do |server, worker|
  # a .oldbin file exists if unicorn was gracefully restarted with a USR2 signal
  # we should terminate the old process now that we're up and running
  old_pid = "#{root}/tmp/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid)
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end