require "time"

namespace :doc do
  desc "Build the manual"
  task :build do
    ENV['RONN_MANUAL']  = "Kibo Manual"
    ENV['RONN_ORGANIZATION'] = "Kibo #{Kibo::VERSION}"
    sh "ronn -w -s toc -r5 --markdown man/*.ronn"
  end

  desc "Commit the manual to git"
  task :commit => :build do
    sh "git add README.md"
    sh "git commit -am 'update docs' || echo 'nothing to commit'"
  end

  desc "Generate the Github docs"
  task :gh_pages => :commit do
    sh %{
      cp man/foreman.1.html /tmp/foreman.1.html
      git checkout gh-pages
      rm ./index.html
      cp /tmp/foreman.1.html ./index.html
      git add -u index.html
      git commit -m "saving man page to github docs"
      git push origin -f gh-pages
      git checkout master
    }
  end
end
