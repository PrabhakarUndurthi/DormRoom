require 'test_helper'

class UserFriendshipTest < ActiveSupport::TestCase
  should belong_to(:user)
  should belong_to(:friend)


  test "that creating a friendship works without raising an exception" do
    assert_nothing_raised do 
  	UserFriendship.create user: users(:prabhakar), friend: users(:brad)
  	end
  end

  test "that creating a friendship based on user id and friend is works"do

   UserFriendship.create user_id: users(:prabhakar).id, friend_id: users(:brad).id
   assert users(:prabhakar).friends.include?(users(:brad)) 
  end
end
