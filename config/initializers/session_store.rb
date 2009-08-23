# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_halen_session',
  :secret      => '507e30b67436cd7dfa2066aa9c01c2ed3076dd4c7aa95e42aef4a46d46ee1f0e2a54d51781e195d2e78b4f80301cfd0d8db8b624c9bc32e462a137fa3945ac49'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
