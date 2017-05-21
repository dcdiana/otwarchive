module ActiveRecord
  class Base
    before_save :update_sanitizer_version
    def update_sanitizer_version
      Configurable.FIELDS_ALLOWING_HTML.each do |field|
        if self.respond_to?("#{field}_changed?") && self.send("#{field}_changed?")
          self.send("#{field}_sanitizer_version=", Configurable.SANITIZER_VERSION)
        end
      end
    end    
  end 
end 
