# Create random key and token and store them in a file

# File name and default value
secrets_hash = { 
  :secret_key => '_railsapp_session',
  :secret_token => '335a4e365ef2daeea969640d74e18f0e3cd9fae1abd8f4125691a880774ea6d456a29c0831aa6921bf86a710fe555e916f0673f5657619ec9df22e0409bec345'
}

secrets_hash.each do |name,default|
  # Set path to secret file
  secret_file = File.join(ENV['OPENSHIFT_DATA_DIR'],name.to_s)
  # Set default value
  secret = default
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
      key = ActiveSupport::SecureRandom.hex(default.length)
      # Write the key to the file
      File.open(secret_file,'w'){ |f| f.write key }
      # Retry reading it to ensure it will work next time
      if retries > 0
        retries -= 1
        retry
      else
        # Log error
      end
    rescue IOError => e
      # Could not write to file
      # Log error
    end
  end
  Railsapp::Application.config.send("#{name}=",secret)
end
