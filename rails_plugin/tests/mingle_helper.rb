module RandomString
  def size_32
    md5 = Digest::MD5::new
    now = Time.now
    md5.update(now.to_s)
    md5.update(now.usec.to_s)
    md5.hexdigest
  end
  module_function :size_32
end

class NoOpMingleRevisionRepository
  def sew_in_most_recent_changeset_data_from_mingle(children)
  end
end


# Stub Mingle's NoSuchRevisionError, which must be thrown by the plugin
# in a couple of places in order for Mingle to work correctly.  
#
# This code is included here because GitRepository raises this exception. This
# requires that some definition of the module be present in test code in order for tests to run.
# When deployed to Mingle, Mingle will supply this code.  
#
# TODO: I'd love to kill this dependency
class Repository  
  class NoSuchRevisionError < StandardError
  end
end

# RepositoryModelHelper is a direct copy of Mingle source that allows for the existing
# SVN and Perforce plugins to have fairly simple controllers. Mixing this module into your
# configuration allows for save to know whether to perform a simple update of the model
# or a delete, while saving a copy with applied changes.  The latter being appropriate
# when a fresh repository synch is needed, e.g., the repository path is changed.
#
# This code is included here because GitConfiguration mixes in this model. This
# requires that some definition of the module be present in test code in order for tests to run.
# When deployed to Mingle, Mingle will supply this code.  
module RepositoryModelHelper
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    
    # depends upon :repository_location_changed?, :mark_for_deletion
    def create_or_update(project_id, id, options={})
      options = options.symbolize_keys
      options.delete(:project_id)
      options.delete(:id)

      if !id.blank? && config = self.find_by_project_id_and_id(project_id, id)
        if config.username != options[:username].to_s.strip
          config.password = nil
        end

        if config.repository_location_changed?(options.dup)
          config.mark_for_deletion
          create_or_update(project_id, nil, config.clone_repository_options.merge(options))
        else
          config.update_attributes(options)
          config
        end
      else
        options.merge! :project_id => project_id
        self.create(options)
      end
    end
  end
  
  #overwrite this method if behaviour is different
  def mark_for_deletion
    update_attribute :marked_for_deletion, true
  end  
end

# Most all Mingle models use this to trim leading and trailing whitespace
# before writing to the database.  You can use this in your configuration model
# if you wish the same convenience. 
#
# This code is included here because GitConfiguration uses strip_on_write. This
# requires that some definition of the module be present in test code in order for tests to run.
# When deployed to Mingle, Mingle will supply this code.  
class ActiveRecord::Base
  class << self
    def strip_on_write(options={})
      return if instance_methods.include?("write_attribute_with_strip")
      exceptions = options[:except] || []
      self.send(:define_method, :should_strip?, lambda do |attribute_name|
        !(options[:except] || []).include?(attribute_name.to_sym)
      end)
      
      self.send(:define_method, :write_attribute_with_strip, lambda do |attribute_name, value|
        if should_strip?(attribute_name) && value.respond_to?(:trim)
          value = value.trim
        end
        write_attribute_without_strip(attribute_name, value)
      end)
      
      alias_method_chain :write_attribute, :strip
    end
  end  
end
