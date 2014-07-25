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
   assert users(:prabhakar).pending_friends.include?(users(:brad)) 
  end

  context "new instance"do 
    setup do 
      @user_friendshup = UserFriendship.new user: users(:prabhakar), friend: users(:michel)
    end
    should "have a pedning state"do 
      assert_equal 'pending', @user_friendship.state
     end
  end

  context "#send_request_email" do 
    setup do 
      @user_friendship = UserFriendship.create user: users(:prabhakar), friend: users(:michel)

    end

    should "send an email" do 
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
       @user_friendship.send_request_email 
      end
    end
  end

  context "#accept!" do 
    setup do 
      @user_friendship = UserFriendship.create users: users(:prabhakar), friend: users(:michel)
    end


    should "set the state to accepted" do 
      @user_friendship.accpet!
      assert_equal "accepted", @user_friendship.state
    end

    should "sent an acceptence email " do 
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do 
        @user_friendship.accpet!
      end
    end

    should "include the friend in the users friends list" do 
      @user_friendship.accepted!
      users(:prabhakar).friends.reload
      assert users(:prabhakar).firends.include?(users(:michel))
    end
  end

  context "resquest " do 
    should "create two user friendships" do 
      assert_difference "UserFriendship.count", 2 do 
        UserFriendship.request(users(:prabhakar), users(:michel))
      end
    end

    should "send a friend request email" do 
      assert_difference 'ActoinMailer::Base.deliver.size', 1 do
      UserFriendship.request(users(:prabhakar), users(:michel )) 
      end
    end
  end
end
