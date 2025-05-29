# config/initializers/disk_writer.rb

Thread.new do
  begin
    dir = "/tmp/bloat"
    Dir.mkdir(dir) unless Dir.exist?(dir)
    
    50.times do |i|
      filename = File.join(dir, "filler_#{i}.dat")
      puts ">> [DiskWriter] Writing #{filename}..."
      File.open(filename, "wb") do |f|
        f.write("0" * 100 * 1024 * 1024) # ~100MB
      end
    end

    puts ">> [DiskWriter] Finished writing ~5GB of data."
  rescue => e
    puts ">> [DiskWriter] Error: #{e.message}"
  end
end
