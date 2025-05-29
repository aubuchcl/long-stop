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
  puts ">> Worker booted (PID: #{Process.pid})"
end

on_worker_shutdown do
  puts ">> Worker shutting down (PID: #{Process.pid}) — simulating stuck cleanup"
  puts ">> [FakeQueue] Waiting for job thread to finish (never does)"

  # Simulated never-ending background job
  Thread.new do
    loop do
      puts ">> [FakeJob] Still running..."
      sleep 5
    end
  end

  # Peg real CPU cores using forked infinite loops (bypass Ruby's GIL)
  cpu_cores = ENV.fetch("CPU_HOG_PROCESSES", 4).to_i

  cpu_cores.times do |i|
    fork do
      puts ">> [CPU Hog #{i}] Forked child pegging CPU on core #{i}"
      loop { 1 + 1 } # Tight loop, high CPU pressure
    end
  end

  # Block shutdown forever
  loop { sleep 10 }
end

at_exit do
  puts ">> Master at_exit triggered (PID #{Process.pid}) — simulating master hang"
  loop { sleep 5 }
end

plugin :tmp_restart
