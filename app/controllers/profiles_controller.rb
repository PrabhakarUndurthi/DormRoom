class ProfilesController < ApplicationController



# Sicne it is profile controller, find the user by the profile_name
# and display the list of statuses belongs to that user.
# If the user is not found, then render the error page.
  def show
  	@user = User.find_by_profile_name(params[:id])
  	if @user 
  		@statuses = @user.statuses.all
  		render action: :show
  	else
  	render file: 'public/404', status:404, formats:[:html]
   end
  end
end
