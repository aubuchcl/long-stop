# frozen_string_literal: true

max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5).to_i
min_threads_count = ENV.fetch("RAILS_MIN_THREADS", max_threads_count).to_i
threads min_threads_count, max_threads_count

worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

port ENV.fetch("PORT", 3000)
environment ENV.fetch("RAILS_ENV", "development")
workers ENV.fetch("WEB_CONCURRENCY", 2).to_i

preload_app!

on_worker_boot do
  puts ">> Worker booted (PID: #{Process.pid}) — simulating CPU load"

  cpu_cores = ENV.fetch("CPU_HOG_PROCESSES", 4).to_i

  cpu_cores.times do |i|
    fork do
      puts ">> [CPU Hog #{i}] Forked child pegging CPU on core #{i}"
      loop { 1 + 1 } # Tight loop
    end
  end

  Thread.new do
    loop do
      puts ">> [BackgroundJob] Running..."
      sleep 5
    end
  end
end

on_worker_shutdown do
  puts ">> Worker shutting down (PID: #{Process.pid}) — simulating stuck cleanup"
  puts ">> [FakeQueue] Waiting for job thread to finish (never does)"

  Thread.new do
    loop do
      puts ">> [FakeJob] Still running..."
      sleep 5
    end
  end

  loop { sleep 10 } # Block shutdown indefinitely
end

at_exit do
  puts ">> Master at_exit triggered (PID #{Process.pid}) — simulating master hang"
  loop { sleep 5 }
end

plugin :tmp_restart

