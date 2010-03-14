class DeviseViewsGenerator < Rails::Generators::Base
  desc "Copies all Devise views to your application."
  
  argument :scope, :required => false, :default => nil,
                   :desc => "The scope to copy views to"
  
  class_option :engine, :type => :string, :aliases => "-t", :default => "erb",
                        :desc => "Template engine for the views. Available options are 'erb' and 'haml'."
  
  def self.source_root
    @_devise_source_root ||= File.expand_path("../../../../app/views", __FILE__)
  end

  def copy_views
    case options[:engine]
    when "erb"
      directory "devise", "app/views/devise/#{scope}"
    when "haml"
      verify_haml_existence
      verify_haml_version
      create_and_copy_haml_views
    end
  end
  
  protected
  
  def verify_haml_existence
    begin
      require 'haml'
    rescue LoadError
      say "HAML is not installed, or it is not specified in your Gemfile."
      exit
    end
  end
  
  def verify_haml_version
    unless Haml.version[:major] >= 2 and Haml.version[:minor] >= 3
      say "To generate HAML templates, you need to install HAML 2.3 or above."
      exit
    end
  end
  
  def create_and_copy_haml_views
    devise_html_source_root = "#{DeviseViewsGenerator.source_root}/devise"
    devise_haml_source_root = "#{DeviseViewsGenerator.source_root}/devise-haml"
    
    # reset the ghost folder so that no deprecated files (if any) will get copied across
    FileUtils.remove_dir devise_haml_source_root, true
    
    Dir["#{devise_html_source_root}/**/*"].each do |path|
      relative_path = path.sub(devise_html_source_root, "")
      source_path   = (devise_haml_source_root + relative_path).sub(/erb$/, "haml")
      
      if File.directory?(path)
        FileUtils.mkdir_p source_path
      else
        `html2haml -r #{path} #{source_path}`
      end
    end
    
    directory devise_haml_source_root, "app/views/devise/#{scope}"
  end
end