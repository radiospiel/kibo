#
# 
module Kibo::Commands
  subcommand :compress, "compress JS and CSS files" do
    opt :quiet, "Be less verbose.", :short => "q"
  end
  
  def compress
    Kibo::CommandLine.args.each do |path|
      compress_dir path
    end
  end
  
  private

  def yuicompressor(*args)
    yuipath = File.join(File.dirname(__FILE__), "..", "bin")
    yuicompressor = "#{yuipath}/yuicompressor-2.4.7.jar"
    Kibo::System.sys! "java", "-jar", yuicompressor, *args
  end
  
  def compress_dir(dir)
    css_files = Dir.glob File.join(dir, "**/*.css")
    js_files = Dir.glob File.join(dir, "**/*.js")

    files = css_files + js_files

    old_sizes = files.inject({}) do |hash, file|
      hash.update file => File.size(file)

      file = file + ".gz"
      hash.update file => File.size(file)
    end

    unless css_files.empty?
      B "Compressing #{css_files.length} CSS files" do
        yuicompressor "--type", "css", "-o", '.css$:.css.min', *css_files, :quiet
      end
    end
    unless js_files.empty?
      B "Compressing #{js_files.length} JS files" do
        yuicompressor "--type", "js", "-o", '.js$:.js.min', *js_files, :quiet
      end
    end

    unless files.empty?
      B "gzipping #{files.length} files" do
        files.each do |file|
          FileUtils.cp "#{file}.min", file
          Kibo::System.sys! "gzip", "-9", "-f", file, :quiet
          FileUtils.mv "#{file}.min", file
        end
      end
    end

    Kibo::Helpers::Info.print do |info|
      old_sum, new_sum = 0, 0

      log_file = lambda do |file|
        old_size, new_size = old_sizes[file], File.size(file)

        unless Kibo::CommandLine.quiet?
          info.line file, "#{old_size} -> #{new_size}"
        end
        old_sum += old_size
        new_sum += new_size
      end
      
      info.head "JS" unless Kibo::CommandLine.quiet?
      
      js_files.sort.each do |file|
        log_file.call(file)
      end
      
      info.head "CSS" unless Kibo::CommandLine.quiet?
      
      css_files.sort.each do |file|
        log_file.call(file)
      end

      info.head "Summary" unless Kibo::CommandLine.quiet?
      
      if old_sum > 0
        info.line "#{files.length} files", "#{old_sum} -> #{new_sum} byte: #{(new_sum * 100.0 / old_sum).round(1)} %"
      else
        info.line "#{files.length} files", "#{old_sum} -> #{new_sum} byte"
      end
    end
  end
end
