desc "Bump the version number"
task :bump do
  version_file = File.expand_path("../../lib/kibo/version.rb", __FILE__)
  sh "ruby #{version_file} > #{version_file}.new"
  sh "mv #{version_file}.new #{version_file}"
end

task :release => :bump
