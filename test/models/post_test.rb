require 'test_helper'

class PostTest < ActiveSupport::TestCase
   	test "the truth" do
    	assert true
  	end

  	test "should not save post without title && body" do
	  	#creat blank post without params
	  	post = Post.new()
	  	#this should not save (assert_not means if the action fails, to succeed in the test. If val is true, test fails)
	  	assert_not post.save
	end





end

