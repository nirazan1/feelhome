ActiveAdmin.register User do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :contact_number, :email, :encrypted_password, :agent, :admin, :reset_password_token, :reset_password_sent_at, :remember_created_at, :current_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :last_sign_in_at, :customer
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  controller do
    def update
      if params[:user][:encrypted_password].blank?
        params[:user].delete("encrypted_password")
      end
      super
    end
  end


end
