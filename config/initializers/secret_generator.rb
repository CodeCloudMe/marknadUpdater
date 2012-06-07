# Create random key and token and store them in a file

def initialize_secrets(secrets_hash)
  secrets_hash.each do |name,default|
    # Set default value
    secret = default

    if ENV['OPENSHIFT_DATA_DIR']
      # Set path to secret file
      secret_file = File.join(ENV['OPENSHIFT_DATA_DIR'],name.to_s)
      # Only retry 3 times
      retries = 3
      begin
        # Try to read a secret file if it exists
        File.open(secret_file) do |f|
          _secret = f.read.chomp
          # Raise error to write file if it's empty
          raise Errno::ENOENT if _secret.length == 0
          secret = _secret
        end
      rescue Errno::ENOENT => e
        begin
          # Generate a secure random hex string
          #  This is the same function that 'rake secret' uses
          key = SecureRandom.hex(default.length)
          # Write the key to the file
          File.open(secret_file,'w'){ |f| f.write key }
          # Retry reading it to ensure it will work next time
          if retries > 0
            retries -= 1
            retry
          else
            # Should probably never get to a point where we can write the file but not read it
            Rails.logger.warn "!!! Unable to read generate secure token after 3 tries, using defaults"
          end
        rescue Errno::ENOENT, Errno::EACCES, IOError => e
          # Could not write to the file
          Rails.logger.warn "!!! No secret stored and unable to write to file, using default"
        end
      rescue Errno::EACCES => e
        Rails.logger.warn "!!! Unable to access file, using default"
      end
    else
      Rails.logger.warn "!!! Not running on OpenShift, using default"
    end

    case name
    when :secret_key
      Railsapp::Application.config.session_store :cookie_store, :key => secret
    when :secret_token
      Railsapp::Application.config.secret_token = secret
    end
  end
end

# File name and default value
secrets_hash = { 
  :secret_key   => '8b81fad69503ca6582514730e65f0e524c6066040aa11db7dc6845d86a2d468dcab5a69ede8867a23a4831b1dfb50c78ff1bfbae1f4fc4789d4b361e54e73c9d',
  :secret_token => 'f69cf1f1ff52ad87a9d1ae8fb5c2e9624149d27326dccf824bc200f558ef634c23102c192059bfcef1c74cad2c85ea290f60f93108ab21caf5ff364e6faa3997'
}

initialize_secrets(secrets_hash)
