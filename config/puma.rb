# config/puma.rb

require 'securerandom'
require 'digest'

max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }
worker_timeout 3600 if ENV.fetch("RAILS_ENV") == "development"

workers ENV.fetch("WEB_CONCURRENCY") { 20 }
preload_app!
plugin :tmp_restart

on_worker_boot do
  puts ">> Worker #{Process.pid} booting — simulating startup load"

  # Simulate disk write (~250MB per worker)
  Thread.new do
    file_path = File.join("tmp", "worker-#{Process.pid}.dat")
    File.open(file_path, "wb") do |f|
      250.times do
        f.write(Random.new.bytes(1_000_000)) # 1MB chunk
        sleep 0.02
      end
    end
    puts ">> Disk write finished for worker #{Process.pid}"
  end

  # Simulate moderate CPU pressure
  Thread.new do
    loop do
      Digest::SHA256.hexdigest(SecureRandom.uuid)
      sleep 0.005
    end
  end
end

on_worker_shutdown do
  puts ">> Worker shutting down (PID: #{Process.pid}) — simulating stuck cleanup"

  # Fake hanging job thread
  Thread.new do
    loop do
      puts ">> [FakeJob] Still running..."
      sleep 10
    end
  end

  # Hard block shutdown
  loop do
    sleep 10
  end
end
