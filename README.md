# PTO
  Paid Take off

 # How to run the app locally?
 Dependencies
 1) Install ruby 2.3.1 using the following command `rvm install 2.3.1`
 2) Install mysql locally using homebrew


 `gem install bundler` # Installs bundler

 `bundle install` # Installs the gems

 `bundle exec rake db:create` # To create the database

 `bundle exec rake db:migrate` # To run the migrations

Setup a valid .env file that defines the required ENV variables.

 `bundle exec rails s` # Start the rails server.

 Open 'http://localhost:3000' in your browser.
