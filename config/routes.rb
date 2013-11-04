AdserveExampleDe::Application.routes.draw do
  root :to => "welcome#index"
  
  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  post "log_in" => "sessions#create", :as => "log_in"
  
  match "signup_advertiser" => "advertisers#new", :as => "signup_advertiser"
  match "signup_publisher" => "publishers#new", :as => "signup_publisher"
  match "signup_admin" => "admins#new", :as => "signup_admin"

  get "publishers_home" => "publishers#home"
  get "publishers_websites" => "publishers#websites"
  get "publishers_find_campaigns" => "publishers#find_campaigns"
  get "publishers_show_campaign" => "publishers#show_campaign"
  post "publishers_apply_for_campaign" => "publishers#apply"
  get "publishers_messages" => "publishers#messages"
  get "publishers_billing" => "publishers#billing"
  get "publishers_analysis" => "publishers#analysis"
  get "publishers_help" => "publishers#help"
  
  match "websites_add" => "websites#create", :as => "websites_add"
  post  "websites_find" => "websites#find", :as => "websites_find"

  get "advertisers_home" => "advertisers#home"
  get "advertisers_campaigns" => "advertisers#campaigns"
  get "advertisers_billing" => "advertisers#billing"
  get "advertisers_find_websites" => "advertisers#find_websites"
  get "advertisers_messages" => "advertisers#messages"
  get "advertisers_analysis" => "advertisers#analysis"
  get "advertisers_help" => "advertisers#help"
  post "advertisers_handle_message" => "advertisers#handle_message"
  
  match "campaigns_add" => "campaigns#create", :as => "campaigns_add"
  match "ads_add" => "ads#create", :as => "ads_add"
  post  "campaigns_find" => "campaigns#find", :as => "campaigns_find"
  
  get "admins_home" => "admins#home"
  get "admins_campaigns" => "admins#campaigns"
  get "admins_websites" => "admins#websites"

  resources :admins
  resources :advertisers
  resources :publishers
  resources :sessions

# The priority is based upon order of creation:
# first created -> highest priority.

# Sample of regular route:
#   match 'products/:id' => 'catalog#view'
# Keep in mind you can assign values other than :controller and :action

# Sample of named route:
#   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
# This route can be invoked with purchase_url(:id => product.id)

# Sample resource route (maps HTTP verbs to controller actions automatically):
#   resources :products

# Sample resource route with options:
#   resources :products do
#     member do
#       get 'short'
#       post 'toggle'
#     end
#
#     collection do
#       get 'sold'
#     end
#   end

# Sample resource route with sub-resources:
#   resources :products do
#     resources :comments, :sales
#     resource :seller
#   end

# Sample resource route with more complex sub-resources
#   resources :products do
#     resources :comments
#     resources :sales do
#       get 'recent', :on => :collection
#     end
#   end

# Sample resource route within a namespace:
#   namespace :admin do
#     # Directs /admin/products/* to Admin::ProductsController
#     # (app/controllers/admin/products_controller.rb)
#     resources :products
#   end

# You can have the root of your site routed with "root"
# just remember to delete public/index.html.
# root :to => 'welcome#index'

# See how all your routes lay out with "rake routes"

# This is a legacy wild controller route that's not recommended for RESTful applications.
# Note: This route will make all actions in every controller accessible via GET requests.
# match ':controller(/:action(/:id))(.:format)'
end
