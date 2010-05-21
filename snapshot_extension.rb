# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class SnapshotExtension < Radiant::Extension
  version "1.0"
  description "Create a static HTML snapshot of your site."
  url "http://www.saturnflyer.com/"
  
  extension_config do |config|
    config.gem 'rubyzip', :lib => 'zip/zip'
  end
  
  define_routes do |map|
    map.namespace :admin do |admin|
      admin.resources :snapshot, :only => [:index, :create]
    end
  end
  
  def activate
    admin.pages.index.add :bottom, 'snapshot'
    # admin.tabs.add "Snapshot", "/admin/snapshot"
  end
  
  def deactivate
  end
  
end
