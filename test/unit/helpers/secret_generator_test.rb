require 'test_helper'

class SecretGeneratorTest < ActiveSupport::TestCase
  # Ensure we're using a temporary directory for OPENSHIFT_DATA_DIR
  setup do
    @defaults = {
      :secret_key   => 'super_secret_cookie_key',
      :secret_token => 'super_secret_token'
    }
    @tempdir = Dir.mktmpdir
    ENV['OPENSHIFT_DATA_DIR'] = @tempdir
  end

  # Ensure we remove the OPENSHIFT_DATA_DIR when we're done
  teardown do
    if @tempdir && File.directory?(@tempdir)
      FileUtils.remove_entry_secure @tempdir
    end
  end

  def unset_data_dir
    ENV['OPENSHIFT_DATA_DIR'] = nil
  end

  def should_not_be(hash)
    run_assertions(hash,false)
  end

  def should_be(hash)
    run_assertions(hash)
  end

  def run_assertions(expected,match = true)
    get_vals.each do |key,value|
      assert_not_nil value
      assert_not_equal '', value

      if match
        assert_equal expected[key], value 
      else
        assert_not_equal expected[key], value 
      end
    end
  end

  def get_vals
    {
      :secret_token => Rails.application.config.secret_token,
      :secret_key =>   Rails.application.config.session_options[:key]
    }
  end

  def each_file
    ['secret_token','secret_key'].each do |file|
      yield File.join(@tempdir,file)
    end
  end

  # These tests ensure that we have the right behavior depending on if we have access to OPENSHIFT_DATA_DIR
  #  and whether the file has already been generated
  test 'it should use default values if no directory given' do
    unset_data_dir
    initialize_secrets(@defaults)
    should_be(@defaults)
  end

  test 'it should use defaults if cannot write file' do
    each_file do |file|
      File.open(file,'w',000)
    end
    initialize_secrets(@defaults)
    should_be(@defaults)
  end

  test 'it should use random value if file empty' do
    each_file do |file|
      File.open(file,'w'){|f| f.write '' }
    end
    initialize_secrets(@defaults)
    should_not_be(@defaults)
  end

  test 'it should reuse values if it can write file' do
    # Run the first time to set the variables
    initialize_secrets(@defaults)
    should_not_be(@defaults)
    expected = get_vals

    # Running the second time should reuse variables
    initialize_secrets(@defaults)
    should_be(expected)
  end
end
