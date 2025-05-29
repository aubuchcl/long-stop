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
  puts ">> Worker shutting down (PID: #{Process.pid}) — simulating background thread hang"

  # Simulate a stuck background job
  thread = Thread.new do
    puts ">> [BackgroundJob] Simulating long-running job in shutdown"
    loop do
      # Simulates a job loop or polling that never gets cancelled
      sleep 10
    end
  end

  # Main shutdown thread waits for the background job
  begin
    thread.join
  rescue => e
    puts ">> Error joining thread: #{e.message}"
  end

  puts ">> Worker finished shutdown (PID: #{Process.pid})"
end


plugin :tmp_restart
