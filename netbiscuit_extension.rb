# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class NetbiscuitExtension < Radiant::Extension
  version "1.0"
  description "Extension for NetBiscuit integration"
  url "http://yourwebsite.com/netbiscuit"
  
  # extension_config do |config|
  #   config.gem 'some-awesome-gem
  #   config.after_initialize do
  #     run_something
  #   end
  # end

  # See your config/routes.rb file in this extension to define custom routes
  
  def activate
    # tab 'Content' do
    #   add_item "Netbiscuit", "/admin/netbiscuit", :after => "Pages"
    # end

    Page.send :include, NbTags
  end
end
