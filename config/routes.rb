Otwarchive::Application.routes.draw do
  
  #### ERRORS ####
  
  match '/403', :to => 'errors#403'
  match '/404', :to => 'errors#404'
  match '/422', :to => 'errors#422'
  match '/500', :to => 'errors#500'

  #### DOWNLOADS ####

  match 'downloads/:download_prefix/:download_authors/:id/:download_title.:format' => 'downloads#show', :as => 'download'

  #### STATIC CACHED COLLECTIONS ####

  namespace 'static' do
    resources :collections, :only => [:show] do
      resources :media, :only => [:show]
      resources :fandoms, :only => [:index, :show]
      resources :works, :only => [:show]
      resources :restricted_works, :only => [:index, :show]
    end
  end
  
  


  #### USERS ####

  resources :people, :only => [:index] do
    collection do
      get :search
    end
  end

  resources :passwords, :only => [:new, :create]

  # When adding new nested resources, please keep them in alphabetical order
  resources :users do
    member do
      get :browse
      get :change_email
      post :change_email
      get :change_password
      post :change_password
      get :change_username
      post :change_username
      post :end_first_login
      post :end_banner
    end
    resources :assignments, :controller => "challenge_assignments", :only => [:index] do
      collection do
        put :update_multiple
      end
      member do
        get :default
      end
    end
    resources :claims, :controller => "challenge_claims", :only => [:index]
    resources :bookmarks
    resources :collection_items, :only => [:index, :update, :destroy] do
      collection do
        put :update_multiple
      end
    end
    resources :collections, :only => [:index]
    resources :comments do
      member do
        put :approve
        put :reject
      end
    end
    resources :external_authors do
      resources :external_author_names
    end
    resources :gifts, :only => [:index]
    resource :inbox, :controller => "inbox" do
      member do
        get :reply
        get :cancel_reply
      end
    end
    resources :invitations do
      member do
        post :invite_friend
      end
      collection do
        get :manage
      end
    end
    resources :nominations, :controller => "tag_set_nominations", :only => [:index]
    resources :preferences, :only => [:index, :update]
    resource :profile, :only => [:show], :controller => "profile"
    resources :pseuds do
      resources :works
      resources :series
      resources :bookmarks
    end
    resources :readings do
      collection do
        post :clear
      end
    end
    resources :related_works
    resources :series do
      member do
        get :manage
      end
      resources :serial_works
    end
    resources :signups, :controller => "challenge_signups", :only => [:index]
    resources :skins, :only => [:index]
    resources :stats, :only => [:index]
    resources :subscriptions, :only => [:index, :create, :destroy]
    resources :tag_sets, :controller => "owned_tag_sets", :only => [:index]    
    resources :works do
      collection do
        get :drafts
        get :collected
        get :show_multiple
        post :edit_multiple
        put :update_multiple
        post :delete_multiple
      end
    end
  end


  #### WORKS ####

  resources :works do
    collection do
      post :import
      get :search
    end
    member do
      get :preview
      post :post
      put :post_draft
      get :navigate
      get :edit_tags
      get :preview_tags
      put :update_tags
      get :marktoread
      get :confirm_delete
    end
    resources :bookmarks
    resources :chapters do
      collection do
        get :manage
        post :update_positions
      end
      member do
        get :preview
        post :post
      end
      resources :comments
    end
    resources :collections
    resources :collection_items
    resources :comments do
      member do
        put :approve
        put :reject
      end
    end
    resources :links, :controller => "work_links", :only => [:index]          
  end

  resources :chapters do
    member do
      get :preview
      post :post
    end
    resources :comments
  end

  resources :external_works do
    collection do
      get :compare
      post :merge
      get :fetch
    end
    resources :bookmarks
    resources :related_works
  end
  
  resources :related_works
  resources :serial_works
  resources :series do
    member do
      get :manage
      post :update_positions
    end
    resources :bookmarks
  end



  #### SESSIONS ####

  resources :user_sessions, :only => [:new, :create, :destroy] do
    collection do
      get :passwd_small
      get :passwd
    end
  end
  match 'login' => 'user_sessions#new'
  match 'logout' => 'user_sessions#destroy'

  #### MISC ####

  resources :comments do
    member do
      put :approve
      put :reject
    end
    collection do
      get :hide_comments
      get :show_comments
      get :add_comment
      get :cancel_comment
      get :add_comment_reply
      get :cancel_comment_reply
      get :cancel_comment_edit
      get :delete_comment
      get :cancel_comment_delete
    end
    resources :comments
  end
  resources :bookmarks do
    collection do
      get :search
    end
    resources :collection_items
  end

  resources :kudos, :only => [:create, :show]

  resources :skins do
    member do
      get :preview
      get :set
    end
    collection do
      get :unset
    end
  end
  resources :known_issues
  resources :archive_faqs do
    collection do
      get :manage
      post :reorder
    end
  end

  resource :redirect, :controller => "redirect", :only => [:show] do
    member do
      get :do_redirect
    end
  end

  resources :abuse_reports
  resources :external_authors do
    resources :external_author_names
  end
  resources :orphans, :only => [:index, :new, :create] do
    collection do
      get :about
    end
  end

  match 'search' => 'works#search'
  match 'support' => 'feedbacks#create', :as => 'feedbacks', :via => [:post]
  match 'support' => 'feedbacks#new', :as => 'new_feedback_report', :via => [:get]
  match 'tos' => 'home#tos'
  match 'tos_faq' => 'home#tos_faq'
  match 'diversity' => 'home#diversity'
  match 'site_map' => 'home#site_map'
  match 'site_pages' => 'home#site_pages'
  match 'first_login_help' => 'home#first_login_help'
  match 'delete_confirmation' => 'users#delete_confirmation'
  match 'activate/:id' => 'users#activate', :as => 'activate'
  match 'devmode' => 'devmode#index'
  match 'donate' => 'home#donate'
  match 'about' => 'home#about'
	match 'menu/browse' => 'menu#browse'
	match 'menu/fandoms' => 'menu#fandoms'
	match 'menu/search' => 'menu#search'	
	match 'menu/about' => 'menu#about'

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
  root :to => "home#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'
end
