max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5).to_i
min_threads_count = ENV.fetch("RAILS_MIN_THREADS", max_threads_count).to_i
threads min_threads_count, max_threads_count

worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"
port ENV.fetch("PORT", 3000)
environment ENV.fetch("RAILS_ENV", "development")
workers ENV.fetch("WEB_CONCURRENCY", 2).to_i

preload_app!

on_worker_boot do
  puts ">> Worker booted (PID: #{Process.pid}) — writing 5GB to disk"

  Thread.new do
    begin
      dir = "/tmp/bloat_#{Process.pid}"
      Dir.mkdir(dir) unless Dir.exist?(dir)

      50.times do |i|
        filename = File.join(dir, "filler_#{i}.dat")
        puts ">> [DiskWriter] Writing #{filename}..."
        File.open(filename, "wb") do |f|
          f.write("0" * 100 * 1024 * 1024)  # 100MB
        end
      end

      puts ">> [DiskWriter] Done writing in PID #{Process.pid}"
    rescue => e
      puts ">> [DiskWriter] Error in PID #{Process.pid}: #{e.message}"
    end
  end
end

plugin :tmp_restart
