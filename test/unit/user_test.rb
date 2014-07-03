require 'test_helper'

class UserTest < ActiveSupport::TestCase

# A user can have many friendships and many friends.
 should have_many(:user_friendships)
 should have_many(:friends)

  test "a user should enter a first name" do
    user = User.new
    assert !user.save
    assert !user.errors[:first_name].empty?
  end

  test "a user should enter a last name" do
    user = User.new
    assert !user.save
    assert !user.errors[:last_name].empty?
  end

  test "a user should enter a profile name" do
    user = User.new
    assert !user.save
    assert !user.errors[:profile_name].empty?
  end

  test "a user should have a unique profile name" do
    user = User.new
    user.profile_name = users(:prabhakar).profile_name
    
    assert !user.save
    assert !user.errors[:profile_name].empty?
  end

  test "a user should have a profile name without spaces" do
    user = User.new(first_name: 'Prabhakar', last_name: 'Undurthi', email: 'undurthi_prabhakar@aol.com')
    user.profile_name = 'Mike The Frog'
    user.password = user.password_confirmation = 'asdfasdf'

    assert !user.save
    assert !user.errors[:profile_name].empty?
    assert user.errors[:profile_name].include?("Must be formatted correctly.")
  end

  test "a user can have a correctly formatted profile name" do
    user = User.new(first_name: 'Michel', last_name: 'Joe', email: 'micheljoe85@gmail.com')
    
    user.password = user.password_confirmation = 'asdfasdf'

    user.profile_name = 'micheljoe_9'
    assert user.valid?
  end

  test "that no error is raised when trying to access a friend list."do 
    assert_nothing_raised do 
      users(:prabhakar).friends
    end
  end


 #create friendship between two users. i.e prabhakar, brad
  test "that creating friendships on a user works"do 
    users(:prabhakar).friends << users(:brad)
    users(:prabhakar).friends.reload
    assert users(:prabhakar).friends.include?(users(:brad))
  end

  test "that calling to_params on  user returns the profile_name"do 
    assert_equal "uprabhakar", users(:prabhakar).to_param
  end
end
