require 'fileutils'
require 'pathname'

dir = ARGV[0]
output_dir = ARGV[1]

unless dir && output_dir
  $stderr.puts "Usage: ruby dp32.rb <dirname> <outputdir>"
  exit 1
end

output_dir = Pathname File.expand_path(output_dir)

if File.exists?(output_dir)
  $stderr.puts "Output dir already exists, aborting"
  exit 1
end

dir = Pathname File.expand_path(dir)

unless File.directory?(dir)
  $stderr.puts "Cannot find directory: #{dir}"
  exit 1
end

audio_depot = dir / 'AudioDepot'
music = dir / 'MUSIC'

unless File.directory?(audio_depot) && File.directory?(music)
  $stderr.puts "Missing AudioDepot and MUSIC subdirectories"
  exit 1
end

Dir[music / '*'].each do |project|
  long_project_name = File.basename project

  unless long_project_name =~ /\d{2}(\d{6})_\d{2}(\d{2})/
    $stderr.puts "Project directory name doesn't match expected pattern: #{long_project_name}"
    exit 1
  end

  short_project_name = [$1, $2, 'p'].join('-')
  project_dir = output_dir / short_project_name
  bounces = project_dir / 'bounces'
  FileUtils.mkdir_p bounces
  projects = project_dir / 'projects'
  FileUtils.mkdir_p projects

  mixdown = Pathname(project) / "#{long_project_name}.WAV"

  if File.exists?(mixdown)
    FileUtils.cp(mixdown, bounces / "#{short_project_name}_mixdown.wav")
  end

  Dir[audio_depot / "#{long_project_name}*.wav"].each do |depot_file|
    long_depot_name = File.basename depot_file

    unless long_depot_name =~ /\d{2}(\d{6})_\d{2}(\d{2})_(.*)\.WAV/
      $stderr.puts "Depot file name doesn't match expected pattern: #{long_depot_name}"
      exit 1
    end

    short_depot_name = [short_project_name, $3].join('_').downcase
    FileUtils.cp(depot_file, bounces / "#{short_depot_name}.wav")
  end

  FileUtils.cp_r project, projects
end
