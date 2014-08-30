class UserFriendshipsController < ApplicationController
	before_filter :authenticate_user!

  respond_to :html, :json

  def index
    @user_friendships = current_user.user_friendships.all
    respond_with @user_friendships
  end

  def accept
    @user_friendship = current_user.user_friendships.find(params[:id])
    #@user_friendship.friend.user_friendships.find_by(friend_id: current_user.id).accept_mutual_friendship!
    if @user_friendship.accept!

      flash[:success] = "You're now friends with #{@user_friendship.friend.first_name}"
    else
      flash[:error] = "That friendship could not be accepted"
    end
    redirect_to user_friendship_path
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

  # If the friend id has key and contains user_friendship relation
  # then create a friendship
  # Once the friendhip is created flash the success message
  # if the friendhip is not created redirect the user to the root path of the website.

  def create
    if params[:user_friendship] && params[:user_friendship].has_key?(:friend_id)
      @friend = User.where(profile_name: params[:user_friendship][:friend_id]).first
      @user_friendship = UserFriendship.request(current_user, @friend)
      respond_to do |format|
        if @user_friendship.new_record?
          format.html do 
            flash[:error] = "Ooops...!There was problem creating that friend request."
            redirect_to profile_path(@friend)
          end
          format.json { render json: @user_friendship.to_json, status: :precondition_failed }
        else
          format.html do
            flash[:success] = "Friend request sent."
            redirect_to profile_path(@friend)
          end
  
          format.json { render json: @user_friendship.to_json }
        end
      end
    else
      flash[:error] = "Friend required"
      redirect_to root_path
    end
  end



  def edit
     @friend = User.where(profile_name: params[:id]).first
     @user_friendship = current_user.user_friendships.where(friend_id: @friend.id).first.decorate
  end


  def destroy
    @user_friendship = current_user.user_friendships.find(params[:id])
    if @user_friendship.destroy
      flash[:success] = "Friendship destroyed"
    end
    redirect_to user_friendships_path
  end
end
