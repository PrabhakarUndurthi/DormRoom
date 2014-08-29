require 'test_helper'

class UserFriendshipsControllerTest < ActionController::TestCase

  context "#index" do 
    context "when not logged in" do 
      should "redirect to the login page" do 
        get :index 
        assert_response :redirect
      end
    end

    context "when logged in" do 
     setup do 
      @friendship1 = create(:pending_user_friendship, user: users(:prabhakar), friend: create(:user, first_name: 'Pending', last_name: 'Friend'))
      @friendship2 = create(:accepted_user_friendship, user: users(:prabhakar), friend: create(:user, first_name: 'Active', last_name: 'Friend'))
        
        sign_in users(:prabhakar)
     get :index 
     end

     should "get the index page without error" do 
      assert_response :success
     end

     should "assign user_friendships" do 
       assert assigns(:user_friendships)
     end

     should "display the user friend's name" do 
      assert_match 'Pending',response.body
      assert_match /Active/, response.body
     end

     should"display pending information on a pending friendship" do 
      assert_select "#user_friendship_#{@friendship1.id}" do
       assert_select "em", "Friendship is pending".
       end 
      end

      should "display the date information on an accepted friendship" do 
        assert_select "#user_friendship_#{@friendship2.id}" do 
          assert_select "em" , "Friendship started #{@friendship2.updated_at}."
        end
      end
     end 

    end
  


  # If the user is curretnly not logged in, then redirect to the login page.
  context "#new"do 
    context "when not logged in"do 
      should "redirect to the login page"do
       get :new
       assert_response :redirect 
    end
  end


  # make sure the mutual frienship i s created between the two friends.

  context "#accept mutual_friendship!" do 
    setup do 
      UserFriendship.request users(:prabhakar), friend(:michel)
  end

  should "accept  the mutual friendship!" do 
    friendship1 = users(:prabhakar).user_friendship.where(friend_id: users(:michel).id).first
    friendship2 = users(:michel).user_friendship.where(friend_id: users(:prabhakar).id).frist
    friendship1.accept_mutual_friendship!
    friendship2.reload 

    assert_equal "accepted",  friendship.state 
  end
end

context "#mutual friendship! "
  setup do 
    UserFriendship.request users(:prabhakar), users(:michel)
    friendship1 = users(:prabhakar).user_friendship.where(friend_id: users(:michel).id).first
    friendship2 =  users(:michel).user_friendship.where(friend_id: users(:prabhakar).id).first 
  end

  should " correctly find the mutual friendship" do 
    assert_equal  @friendship2, @friendship1.mutual_friendship
  end
end


# If the user is logged in correctly then flash a success message
   context "when logged in"do 
     setup do 
    	sign_in users(:prabhakar)	
    end

    should "get the new page and return success."do
      get :new
      assert_response :success 
     end


     should " should set a flash error if the friend_id params is missing"do 
       get :new, {}
        assert_equal "Friend required", flash[:error]
     end

     should "display the friend's name"do 
       get :new, friend_id: users(:michel)
       assert_match /#{users(:michel).full_name}/, response.body
     end

     should "assign a new user friendship to the correct friend"do 
       get :new, friend_id: users(:michel)
       assert_equal users(:michel), assigns(:user_friendship).friend
     end

     should "assign a new user friendship to the currently logged in user "do 
       get :new, friend_id: users(:michel) 
       assert_equal users(:prabhakar), assigns(:user_friendship).user
     end

     should " return 404 status if no friend is found."do 
       get :new, friend_id: 'invalid'
       assert_response :not_found
   end

   # after clicking on the add friend, make sure the user clicked the button correctly.

   should "ask if you really want to friend the user"do 
    get :new, friend_id: users(:michel)
    assert_match /Do you really want to  be friend with #{users(:michel).full_name}?/, response.body 
   end
  end
end


# If the user trying to send a friend request ?
# check if the current user is logged in or not, 
#If not then redirect that user to the login page.

  context "#create"do 
   context "when not logged in "do 
     should "redirect to the login page"do 
       get :new
       assert_response :redirect
       assert_redirected_to login_path
      end
    end

  #Once of the user logged in, and sending a friend request,
  #with out any friend id? then set  flash message.

    context "when logged in"do
     setup do 
      sign_in users(:prabhakar)
    end

    context "with no friend_id"do 
      setup do 
      post :create
    end
      should "set the flash error message"do 
      assert !flash[:error].empty?
     end

     should "redirect to the root page" do 
      assert_redirected_to root_path
     end
    end

    # when the user has a valid friend id assign a  new user as a friend.
    # and create the friend relation between the two users.
    # after creating the friendship redirect to the profle page of the new friend.

  context "with a valid friend object"do 
    setup do 
      post :create, user_friendship: {friend_id: users(:brad)}
    end

     should "should assign a friend object"do 
      assert assigns(:friend)
      assert_equal users(:brad), assigns(:friend)
    end

    should "assign a user_friendship object"do 
    assert assigns(:user_friendship)
    assert_equal users(:prabhakar), assigns(:user_friendship).user 
    assert_equal users(:brad), assigns(:user_friendship).friend
  end

    should "create a friendship" do 
      assert users(:prabhakar).pending_friends.include?(users(:brad))
    end

    should "redirect to the profile page of the friend"do 
     assert_response :redirect 
     assert_redirected_to profile_path(users(:brad))
  end

   should "set the flash success message"do 
     assert flash[:success]
     assert_equal "Friend request sent.", flash[:success]
     end
    end
   end
  end

   context "#accept" do 
    context "when not logged in " do 
      should "rediect to the login page"
       put :accept, id: 1
       assert_response :redirect 
       assert_redirected_to login_path 
      end
    end

    context "when logged in " do 
      setup do 
        @user_friendship =create(:pending_user_friendship, user: users(:prabhakar))
        sign_in users(:prabhakar)
        put :accept, id: @user_friendship
        @user_friendship.reload
      end
      should "assign a user_friendship" do 
       assert assigns(:user_friendship)
       assert_equal @user_friendship, assigns(:user_friendship)
      end

      should "update the state to accepted" do 
        assert_equal 'accepted', @user_friendship.state
      end

      should "have a flash success message" do 
        assert_equal "You are now friends with #{@user_friendship.friend.first_name}", flash[:success]
      end
    end

  end


  context "#edit" do
    context "when not logged in " do 
      should "redirect to the login page" do 
        get :edit, id:
        assert_response :redirect
      end
      end

      context"when logged in " do 
        setup do 
          @user_friendship = create(:pending_user_friendship, user: users(:prabhakar))
          sign_in users(:prabhakar) 
          get :edit , id: @user_friendship
        end

        should "get edit and return success" do 
          assert_response :success
        end

         should "assign to the user friendship" do 
           assert assigns(:user_friendship)
         end
         should "assign to friend" do 
          assert assigns(:friend)
         end
        end
    end
    end
  end
end


