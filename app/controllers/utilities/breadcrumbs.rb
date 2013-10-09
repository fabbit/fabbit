# This module manages breadcrumbs.
#
# Breadcrumbs are an array of hashes, with each hash containing a title and a link.

module Breadcrumbs

  class BreadcrumbHelper

    def initialize
      @breadcrumbs = Array.new
    end

    # Add a breadcrumb representation of some object into the breadcrumbs array.
    #
    # The objects can be anything, but to be meaningful, they must have an idea of a title text and a
    # link. For example, a hash with two keys, title and link, will be added and rendered correctly.
    # An array of these hashes will work as well. ActiveRecord models will be linked to its own show
    # page, with the name field of the object as the title of the link. Any other object will
    # generate nils for now, but will have extended support in the future.
    def add(object)
      # Handle special cases first

      if object.is_a? Hash
        @breadcrumbs << process_hash(object)

      elsif object.is_a? ActiveRecord::Base
        @breadcrumbs << process_model(object)

      elsif object.is_a? Array
        object.each do |item|
          self.add(item)    # recursively call add for each item in the array
        end

      else
        @breadcrumbs << process_general

      end

    end

    # Enumerates through the breadcrumbs
    def each(&block)
      @breadcrumbs.each(&block)
    end

    private

      # If the object is a hash, checks the title and link field and generate a crumb.
      def process_hash(object)
        if !object[:title].blank? and object[:link]
          {
            title: object[:title],
            link: object[:link].blank? ? "#" : object[:link],
          }
        end
      end

      # If the object is an ActiveRecord model, check for a name method and generate a crumb.
      def process_model(object, title_field=:name)
        if object.methods.include? title_field
          {
            title: object.name,
            link: object
          }
        end
      end

      # Process the general case.
      #
      # for now, just generate a nil crumb
      def process_general
        { title: nil, link: nil }
      end

    # end private

  end

  @@breadcrumb_helper = BreadcrumbHelper.new

  def self.add(object)
    @@breadcrumb_helper.add(object)
  end

  def self.each(&block)
    @@breadcrumb_helper.each(&block)
  end

  def self.clear(&block)
    @@breadcrumb_helper = BreadcrumbHelper.new
  end
end
