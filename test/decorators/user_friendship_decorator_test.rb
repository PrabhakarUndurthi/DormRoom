require 'test_helper'

class UserFriendshipDecoratorTest < Draper::TestCase


	context "#sub_message" do 
		setup do 
			@friend = create(:user , first_name: 'Michel')
		end


		context "with a pending user friendship" do 
			setup  do 
				@user_friendship = create(:pending_user_friendship, friend: @friend)
				@decorator = UserFriendshipDecorator.decorate(@user_friendship)
			end

			should "return the correct message" do 
				assert_equal "Friend request pending", @decorator.sub_message
			end
		end


		context "with accepted user friendship" do 
			setup do 
				@user_friendship = create(:accepted_user_friendship, friend: @friend)
				@decorator = UserFriendshipDecorator.decorate(@user_friendship)
			end

			should "return the correct message" do 
				assert_equal "<h3> You're now friends with Michel</h3>", @decorator.sub_message
			end
		end
	end




	context "#friendship_state" do 
	    context "wih a pending user friendship" do 
			setup do 
				@user_friendship = create(:pending_user_friendship)
				@decorator = UserFriendshipDecorator.decorate(@user_friendship)
			end
			should "return pending" do 
			   assert_equal 'Pending' , @decorator.friendship_state
			end
		end

		context "with accepted user friendship" do 
			setup do 
				@user_friendship = create(:accepted_user_friendship)
				@decorator = UserFriendshipDecorator.decorate(@user_friendship)
			end
			should "return accepted" do 
				assert_equal 'Accepted', @decorator.friendship_state
			end
		end


		context "with requested user friendship" do 
			setup do 
				@user_friendship = create(:requested_user_friendship)
				@decorator = UserFriendshipDecorator.decorate(@user_friendship)
			end
			should "return requested" do 
				assert_equal 'Requested', @decorator.friendship_state
			end
		end		
	end
end
