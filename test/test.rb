
# Runs the test cases and reports
class Test
  def self.run(parent_dir)
    Dir["#{parent_dir}/*"].select { |path| File.directory?(path) && /\Acase\d+\z/ =~ File.basename(path)  }.sort.each do |path|
      Test.new(path).run
    end
  end

  def initialize(test_case_path)
    @test_case_path = test_case_path
  end

  def run
    time_taken = 0
    report = MemoryProfiler.report do
        t = Time.now
        generate
        time_taken = ((Time.now - t) * 1000).round
      end
    v = verdict

    puts "\n\n\nRunning #{File.basename(@test_case_path)}"
    puts "Verdict: #{v ? "PASS" : "FAIL"}"
    puts "Time Taken: #{time_taken}ms"
    puts "Memory: #{(report.total_allocated_memsize / 1024.0).round(2)}kb"

    cleanup # Remove this if you want to debug a problem by comparing expected and result
  end

  def verdict
    return false unless File.exist?(result_path)

    [result_path, expected_path].each do |path|
      File.open("#{path}.cleaned", 'w') do |f|
        File.foreach(path) do |line|
          next if (line = line.to_s.strip).length.zero?

          f.puts line
        end
      end
    end

    FileUtils.identical?(result_path, expected_path)
  end

  def generate
    App.new("#{@test_case_path}/pages", save_to: result_path).run_script
  rescue StandardError => e
    false
  end

  def cleanup
    FileUtils.rm_f(Dir["#{@test_case_path}/*.tmp"].to_a)
    FileUtils.rm_f(Dir["#{@test_case_path}/*.cleaned"].to_a)
  end

  def result_path
    @result_path ||=
      "#{@test_case_path}/result.tmp".tap do |path|
        FileUtils.rm_f(path)
      end
  end

  def expected_path
    path = "#{@test_case_path}/expected.txt"
    raise("Cannot file expected.txt in #{@test_case_path}") unless File.exist?(path)
    path
  end
end
