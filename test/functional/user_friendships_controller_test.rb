require 'test_helper'

class UserFriendshipsControllerTest < ActionController::TestCase
  context "#new"do 
    context "when not logged in"do 
      should "redirect to the login page"do
       get :new
       assert_response :redirect 
    end
  end

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
      assert users(:prabhakar).friends.include?(users(:brad))
    end

    should "redirect to the profile page of the friend"do 
     assert_response :redirect 
     assert_redirected_to profile_path(users(:brad))
  end

   should "set the flash success message"do 
     assert flash[:success]
     assert_equal "You are now friends with #{users(:brad).full_name}", flash[:success]
     end
    end
   end
  end
end


