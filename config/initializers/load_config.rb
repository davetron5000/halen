require 'gliffy'

APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/config.yml")[RAILS_ENV]
if APP_CONFIG['git_root'] =~ /^\//
  APP_CONFIG[:git_root] = APP_CONFIG['git_root'] 
else
  APP_CONFIG[:git_root] = RAILS_ROOT + "/" +  APP_CONFIG['git_root'] 
end
APP_CONFIG[:wiki_dir] = 'wiki';
APP_CONFIG[:wiki_root] = APP_CONFIG[:git_root] + '/' + APP_CONFIG[:wiki_dir]

begin
  cred = Gliffy::Credentials.new(APP_CONFIG['gliffy_consumer_key'],
                          APP_CONFIG['gliffy_consumer_secret'],
                          APP_CONFIG['gliffy_description'],
                          APP_CONFIG['gliffy_account_id'],
                          APP_CONFIG['gliffy_username'])

  APP_CONFIG[:gliffy] = Gliffy::Handle.new('www.gliffy.com/api/1.0','www.gliffy.com/gliffy',cred)
rescue Exception => ex
  Rails.logger.warn("Gliffy plugin is not going to be available: " + ex)
  APP_CONFIG[:gliffy] = nil
end
