# Create random key based on the OPENSHIFT_SECRET_TOKEN

def initialize_secret(name,default)
  # Only generate token based if we're running on OPENSHIFT
  if secret = ENV['OPENSHIFT_SECRET_TOKEN']
    # Create seed for random function from secret and name
    seed = [secret,name.to_s].join('-')
    # Generate hash from seed
    hash = Digest::SHA512.hexdigest(seed)
    # Set token, ensuring it is the same length as the default
    hash[0,default.length]
  else
    Rails.logger.warn "No secret token provided, using default value"
    default
  end
end
