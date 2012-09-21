# It would be great if we could just use Heroku.read_credentials or `heroku whoami` 
# to check for a user's current login. Well, we can't:
#
# - since heroku aggressively pushes its heroku toolbelt people 
#   might be forced to uninstall the heroku gem.
# - `heroku whoami` blocks for input, if the user is not logged in.
#
# Hence this code, which is based on code from the heroku gem.
#
# == Copyright and licensing ==================================================
#
# The heroku gem is licensed under the terms of the MIT license,
# see the file License.MIT.
#
# The heroku has been created by Adam Wiggins, and is currently maintained
# by Wesley Beary.
module Kibo::Helpers::Heroku
  require "netrc"

  def whoami
    (read_credentials || []).first
  end

  private
  
  def host
    ENV['HEROKU_HOST'] || default_host
  end

  def default_host
    "heroku.com"
  end

  def netrc_path
    default = Netrc.default_path
    encrypted = default + ".gpg"
    if File.exists?(encrypted)
      encrypted
    else
      default
    end
  end

  def netrc   # :nodoc:
    @netrc ||= begin
      File.exists?(netrc_path) && Netrc.read(netrc_path)
    rescue => error
      if error.message =~ /^Permission bits for/
        perm = File.stat(netrc_path).mode & 0777
        abort("Permissions #{perm} for '#{netrc_path}' are too open. You should run `chmod 0600 #{netrc_path}` so that your credentials are NOT accessible by others.")
      else
        raise error
      end
    end
  end

  def read_credentials
    if ENV['HEROKU_API_KEY']
      ['', ENV['HEROKU_API_KEY']]
    else
      # read netrc credentials if they exist
      if netrc
        # force migration of long api tokens (80 chars) to short ones (40)
        # #write_credentials rewrites both api.* and code.*
        credentials = netrc["api.#{host}"]
        if credentials && credentials[1].length > 40
          @credentials = [ credentials[0], credentials[1][0,40] ]
          write_credentials
        end

        netrc["api.#{host}"]
      end
    end
  end
end
