# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_docomoid_session',
  :secret      => '57c6a3f2a068e012c5987ab69d5a3cf2944bf31fb67a3a13803ca21f8e3547b4bbb0a4b0b51865c7cead1f66310e9ed994a1cb94d512c76bd194f0b64a5be69e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
