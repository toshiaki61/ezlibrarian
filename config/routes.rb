match '/treasures', :controller => 'treasures', :action => 'index'
match '/treasures', :controller => 'treasures', :action => 'index_of_devices'

match '/treasures/new_book', :to => "treasures#new_book"
match '/treasures/new_device', :to => "treasures#new_device"

match '/treasures/edit_book', :to => "treasures#edit_book"
match '/treasures/edit_device', :to => "treasures#edit_device"

match '/treasures/:id/add_review', :to => "treasures#add_review"

match '/treasures/:id', :controller => 'treasures', :action => 'show_book'
match '/treasures/:id', :controller => 'treasures', :action => 'show_device'
match '/treasures', :controller => 'treasures', :action => 'show_holder_change_histories'
match '/treasures', :controller => 'treasures', :action => 'destroy_book'
match '/treasures', :controller => 'treasures', :action => 'destroy_device'

#match '/treasures/:id' => 'treasures#show'
