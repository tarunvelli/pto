OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '92335798234-tkn3ssrts2s15f1nk9aqqattid9mf1sk.apps.googleusercontent.com', 
  'ayTLw6dOOm2nDC43buhP_CEk', {client_options: {ssl: {ca_file: Rails.root.join("cacert.pem").to_s}}, hd: 'beautifulcode.in'}
end