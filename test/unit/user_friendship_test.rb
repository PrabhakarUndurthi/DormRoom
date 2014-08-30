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


  contect "#accept_mutual_friendship!" do 
    setup do 
      UserFriendship.request users(:prabhakar), users(:michel)
    end

    should " accept the mutual friendship" do 
      friendship1 = users(:prabhakar).user_friendships.where(friend_id: users(:michel).id).first
      friendship2 = users(:michel).user_friendships.where(friend_id: users(:prabhakar).id).first

      friendship1.accept_mutual_friendship!
      friendship2.reload

      assert_equal "accepted", friendship2.state
    end
  end

  context "#mutual_friendship" do 
    setup do 
      UserFriendship.request users(:prabhakar) , users(:michel)
      @friendship1 = users(:prabhakar).user_friendship.where(friend_id: users(:michel).id).firsrt
      @friendship2 = users(:michel).user_friendship.where(friend_id: users(:prabhakar).id).first


    end

    should "correctly find the mutual friendship " do
      assert_equal  @friendship2, @friendship1.mutual_friendship!
    end
  end


 
  context "#accept!" do 
    setup do 
      @user_friendship = UserFriendship.request users: users(:prabhakar), friend: users(:michel)
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

     should "accept the mutural friendship" do 

      @user_friendship.accept!
      assert_equal "accepted", @user_friendship_mutual_friendship.state
     end
  end

  context "request " do 
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


  context "delete mutual friendship" do 
    setup do 
      UserFriendship.request users(:prabhakar), users(:michel)
      @friendship1 = users(:prabhakar).user_friendship.where(friend_id: users(:michel).id).first 
      @friendship2 = users(:michel).user_friendship.where(friend_id: users(:prabhakar).id).first
    end

    should "delete the mutual friendship" do 

      assert_equal @friendship2, @friendship1.mutual_friendship
      @friendship2.delete_mutual_friendship
      assert !UserFriendship.exists?(@friendship2.id)
    end
  end


  context "on destroy" do 
    setup do 
      UserFriendship.request users(:prabhakar), users(:michel)
      @friendship1 = users(:prabhakar).user_friendship.where(friend_id: users(:michel).id).first 
      @friendship2 = users(:michel).user_friendship.where(friend_id: users(:prabhakar).id).first
    end

    should "delete mutual friendship " do 

      @friendship1.destroy 
      assert !UserFriendship.exists?(@friendship2.id)
    end
  end


 end

