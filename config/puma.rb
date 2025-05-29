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
  puts ">> Worker booted (PID: #{Process.pid}) — simulating disk I/O"

  # Simulate disk I/O: write ~5GB of data
  disk_file = "/tmp/puma_worker_#{Process.pid}_data.dump"
  file_size_gb = ENV.fetch("DISK_WRITE_GB", 5).to_i
  chunk_size_mb = 10
  iterations = (file_size_gb * 1024) / chunk_size_mb

  puts ">> Writing ~#{file_size_gb}GB to #{disk_file} in chunks..."
  Thread.new do
    File.open(disk_file, "wb") do |f|
      iterations.times do |i|
        f.write(Random.new.bytes(chunk_size_mb * 1024 * 1024))
        puts ">> [Disk Writer] Wrote chunk #{i + 1}/#{iterations}"
      end
    end
    puts ">> Finished writing to disk"
  end

  # Simulate long-running background task
  Thread.new do
    loop do
      puts ">> [BackgroundJob] Still running..."
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
# plugin :appsignal  # Commented out unless needed
