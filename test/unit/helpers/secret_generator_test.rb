require 'test_helper'

# Set this just in case the name changes
TOKEN_NAME = 'OPENSHIFT_SECRET_TOKEN'

class SecretGeneratorTest < ActiveSupport::TestCase
  setup do
    @defaults = {
      :session_store  => 'super_secret_cookie_key',
      :token          => 'super_secret_token'
    }
    ENV[TOKEN_NAME] = SecureRandom.hex(64)
  end

  def unset_env
    [TOKEN_NAME,'OPENSHIFT_APP_NAME','OPENSHIFT_APP_UUID'].each do |name|
      ENV[name] = nil
    end
  end

  def should_not_be(defaults,expected=nil)
    run_assertions(defaults,expected,false)
  end

  def should_be(defaults,expected=nil)
    run_assertions(defaults,expected)
  end

  def run_assertions(defaults,expected,match = true)
    results = initialize_secrets(defaults)
    expected ||= defaults

    results.each do |key,value|
      assert_not_nil value
      assert_not_equal '', value
      assert_equal expected[key].length, value.length

      if match
        assert_equal expected[key], value 
      else
        assert_not_equal expected[key], value 
      end
    end
    results
  end

  def initialize_secrets(hash)
    Hash[hash.map do |k,v|
      [k,initialize_secret(k,v)]
    end]
  end

  # These tests ensure our environment is reported correctly
  test "it should not be able to get or create #{TOKEN_NAME}" do
    unset_env
    assert_nil get_env_secret
  end

  test "it should be able to create #{TOKEN_NAME}" do
    unset_env
    ENV['OPENSHIFT_APP_NAME'] = 'name'
    ENV['OPENSHIFT_APP_UUID'] = 'uuid'
    hash = Digest::SHA256.hexdigest(%w(name uuid).join('-'))

    assert_not_nil get_env_secret
    assert_equal hash, get_env_secret
  end

  # These tests ensure that we have the right behavior depending on if 
  #   the secret token environment variable is set properly

  test "it should use default values if #{TOKEN_NAME} not defined" do
    unset_env
    should_be(@defaults)
  end

  test "it should use hashed values if #{TOKEN_NAME} defined" do
    should_not_be(@defaults)
  end

  test "values should be consistent if #{TOKEN_NAME} defined" do
    # Run the first time to set the variables
    results = should_not_be(@defaults)

    # Running the second time should reuse variables
    should_be(@defaults,results)
  end
end
