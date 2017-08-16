ActiveAdmin.register Booking do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
  index do
    selectable_column
    column :id
    column :agent
    column :user
    column :passengers
    column :flight_time
    column :ticket_time_limit
    column :flight_number
    column :airline
    column :origin
    column :destination
    column :pnr
    column :ticket_number
    column :bill_number
    column :currency
    column :amount
    column :recipt_number
    column :ticket_type
    column :created_at
    column :updated_at
    actions :defaults => true
  end

end
