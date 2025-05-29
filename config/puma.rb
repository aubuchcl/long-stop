workers 2
threads 1, 1
preload_app!

$stdout.sync = true
$stderr.sync = true


# Simulate hanging background thread on shutdown
at_exit do
  puts ">> at_exit hook triggered - simulating long shutdown..."
  Thread.new do
    sleep 300 # Simulate a hung thread
  end.join
end

on_worker_boot do
  puts ">> Worker booted (PID: #{Process.pid})"
  STDOUT.flush
end

