class ProfilesController < SecureController
  def edit
  end

  def update
    if params[:profile][:action] == "destroy"
      if current_user.authenticate(params[:profile][:password])
        reset_session
        return redirect_to misc_dashboard_path
      else
        current_user.errors.add(:password, "is invalid")
        return render :edit
      end
    end

    profile_params = params.require(:profile).permit(
      :email, :phone, :firstname, :lastname,
      :country, :state, :city, :zip,
    )

    current_user.assign_attributes(profile_params)

    unless current_user.authenticate(params[:profile][:password])
      current_user.errors.add(:password, "is invalid")
      return render :edit
    end

    if current_user.save
      redirect_to edit_profile_path, notice: 'Your profile was successfully updated.'
    else
      render :edit
    end
  end

  def edit_password
  end

  def update_password
    unless current_user.authenticate params[:profile][:old_password]
      current_user.errors.add :old_password, "is invalid"
      return render :edit_password
    end

    current_user.assign_attributes params.require(:profile).permit(
      :password,
      :password_confirmation,
    )

    if current_user.save(context: :update_password)
      redirect_to edit_profile_path, notice: "Your password has been updated."
    else
      render :edit_password
    end
  end
end
