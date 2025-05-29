# Set up Puma in cluster mode
workers 2
threads 1, 1
preload_app!

# Ensure logs flush immediately
$stdout.sync = true
$stderr.sync = true

# Called in each worker when it boots
on_worker_boot do
  puts ">> Worker booted (PID: #{Process.pid})"
end

# Called in each worker on shutdown – simulate a hang here
on_worker_shutdown do
  puts ">> Worker shutting down - simulating stuck cleanup (PID: #{Process.pid})"
  sleep 300 # Simulate a long-running shutdown task
  puts ">> Worker finished cleanup (PID: #{Process.pid})"
end


