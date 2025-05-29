# config/puma.rb

max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5).to_i
min_threads_count = ENV.fetch("RAILS_MIN_THREADS", max_threads_count).to_i
threads min_threads_count, max_threads_count

worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"
port ENV.fetch("PORT", 3000)
environment ENV.fetch("RAILS_ENV", "development")
workers ENV.fetch("WEB_CONCURRENCY", 2)

preload_app!

at_exit do
  puts ">> Master at_exit triggered (PID #{Process.pid}) — simulating master hang"
  loop { sleep 10 }  # Simulate master process never exiting
end

on_worker_shutdown do
  puts ">> Worker shutting down (PID: #{Process.pid}) — simulating stuck cleanup"
  puts ">> [FakeQueue] Waiting for job thread to finish (never does)"

  # Simulated background thread (low load, still visible)
  Thread.new do
    loop do
      puts ">> [FakeJob] Still running..."
      sleep 10
    end
  end

  # High-CPU background threads to simulate misbehaving shutdown
  4.times do |i|
    Thread.new do
      puts ">> [CPU Hog #{i}] Starting tight loop to peg CPU..."
      loop do
        i = 0
        while i < 10_000_000
          i += 1
          Math.sin(i) * Math.cos(i)
        end
      end
    end
  end

  # Block the shutdown — Puma won't exit until this ends
  loop { sleep 10 }
end

plugin :tmp_restart
