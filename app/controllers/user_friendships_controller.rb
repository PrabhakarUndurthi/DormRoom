class UserFriendshipsController < ApplicationController
	before_filter :authenticate_user!

  def index
    @user_friendships = current_user.user_friendships.all
  end


#create a new friendship,
# if the friend is is missing or of the friend name is missing
# raise an error and return 404 .
 def new
 	if   params[:friend_id]
 		@friend = User.where(profile_name: params[:friend_id]).first
 		raise ActiveRecord::RecordNotFound if @friend.nil?
 		@user_friendship = current_user.user_friendships.new(friend: @friend)
 	else

 		flash[:error] = "Friend required"
 	end
 rescue ActiveRecord::RecordNotFound
 	render file: 'public/404', status: :not_found
  end

  # If the friend is has key and contains user_friendship relation
  # then create a friendship
  # Once the friendhip is created flash the success message
  # if the friendhip is not created redirect the user to the root path of the website.

  def create 
  	 if  params[:user_friendship] && params[:user_friendship].has_key?(:friend_id)
  	 	@friend = User.where(profile_name: params[:user_friendship][:friend_id]).first
  	 	@user_friendship = current_user.user_friendships.new(friend: @friend)
  	 	@user_friendship.save
  	 	flash[:success] = "You are now friends with #{(@friend.full_name)}"
  	 	redirect_to profile_path(@friend)
  	 else
  	 	flash[:error] = "Friend required"
  	 	redirect_to root_path
  	 end
  end

end
