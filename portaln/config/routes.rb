ActionController::Routing::Routes.draw do |map|
                 
  map.pesquisar(
    '/pesquisar/:query', 
    :controller => :pesquisa, 
    :action => :index,
    :defaults => { :query => nil }
  )                                                     
                                                       
  map.noticias_ultimas_feeds(
    '/noticias/ultimas/feeds', 
    :controller => :noticias, 
    :action => :ultimas, 
    :format => 'atom'
  )
  
  map.noticias_tag_feeds(
    '/noticias/:tag/feeds', 
    :controller => :noticias, 
    :action => :index, 
    :format => 'atom'
  )
                                                       
  map.noticias_ultimas(
    '/noticias/ultimas', 
    :controller => :noticias, 
    :action => :ultimas
  )

  map.fotos_show1(
    '/fotos/show/:id/:style',
    :controller => :fotos,
    :action => :show
  )
  
  map.fotos_show2(
    '/images/fotos/show/:id/:style',
    :controller => :fotos,
    :action => :show
  )
  
  map.resources :noticias         
  map.resources :registrations, :only => [:new, :create]
  map.resources :albuns
  map.resources :fotos, :only => :create
  map.resources :contatos, :only => [:index, :create]
  map.resources :configuracoes, :only => [:index, :update]
  map.resources :biografia, :only => [:index]
  
  map.devise_for :users, :path_names => { 
    :sign_in => 'login', 
    :sign_out => 'logout', 
    :sign_up => 'register'
  }
  
  map.new_user_session(
    'login', 
    :controller => 'sessions', 
    :action => 'new', 
    :conditions => { :method => :get }
  )
  
  map.user_session(
    'login', 
    :controller => 'sessions', 
    :action => 'create', 
    :conditions => { :method => :post }
  )
  
  map.destroy_user_session(
    'logout', 
    :controller => 'sessions', 
    :action => 'destroy', 
    :conditions => { :method => :get }
  )
                                  
  map.resources :home, :only => :index
  
  map.find_tag(
    "/tag/find/:name", 
    :controller => :tags, 
    :action => :find
  )
  
  map.tagcloud_noticias(
    "/tag/cloud/noticias", 
    :controller => :tags, 
    :action => :cloud_noticia
  )                            
  
  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  map.root :controller => :home

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
