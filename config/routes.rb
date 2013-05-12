resources :books, :path => 'treasure/books'
match 'treasure/books/borrow/:id', :to => 'books#borrow'
match 'treasure/books/return/:id', :to => 'books#return'
resources :devices, :path => 'treasure/devices'
resources :amazon, :path => 'treasure/amazon', :only => [:index]
resources :reviews, :path => 'treasure/reviews', :only => [:create]
resources :statements, :path => 'treasure/statements', :only => [:index, :create]
resources :histories, :path => 'treasure/histories', :only => [:index]
