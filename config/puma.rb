max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS", max_threads_count)
threads min_threads_count, max_threads_count

worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

port ENV.fetch("PORT", 3000)
environment ENV.fetch("RAILS_ENV", "development")

workers ENV.fetch("WEB_CONCURRENCY", 2)
preload_app!

$stdout.sync = true
$stderr.sync = true

on_worker_boot do
  puts ">> Worker booted (PID: #{Process.pid})"
end

on_worker_shutdown do
  puts ">> Worker shutting down (PID: #{Process.pid}) — simulating stuck cleanup"

  # Simulate a real-world bug: blocking shutdown on resource cleanup
  puts ">> [FakeQueue] Waiting for job thread to finish (never does)"
  
  # Simulate background job running forever
  Thread.new do
    loop do
      puts ">> [FakeJob] Still running..."
      sleep 10
    end
  end

  # BLOCK the shutdown directly — Puma won't exit until this ends
  loop do
    sleep 10
  end
end

at_exit do
  puts ">> Master at_exit triggered (PID #{Process.pid}) — simulating shutdown hang"
  loop { sleep 10 } # instead of sleep 300 — this prevents return
end


plugin :tmp_restart
