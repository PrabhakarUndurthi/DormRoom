require 'test_helper'

class StatusTest < ActiveSupport::TestCase
 

 test "that status  should have the content."do 
   status = Status.new
   assert !status.save
   assert !status.errors[:content].empty?
 end

 test "that status should contain at least 5 characters."do 
   status = Status.new
   status.content = "Hi"
   assert !status.save
   assert !status.errors[:content].empty?

 end



 test "that status has a user id."do
   status = Status.new
   status.content = "Hello"
   assert !status.save
   assert !status.errors[:user_id].empty?
 end
end
