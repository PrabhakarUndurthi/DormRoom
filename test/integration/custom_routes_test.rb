require 'test_helper'

class CustomRoutesTest < ActionDispatch::IntegrationTest

# Testing the login page.	
  test "that /login  route opens the login page"do
   get '/login'
   assert_response :success
end



# When the log out he must be redirected to the root of the application.
  test "that /logout route opens the log out page"do 
   get '/logout'
   assert_response :redirect
   assert_redirected_to  '/'
  end

  #Tessting the registration page.

  test "that /register route opens the sign up page"do
   get '/register'
   assert_response :success 
 end

 test "that /profilename route opens the user profile."do 
 get '/uprabhakar'
 assert_response :success
end
end
