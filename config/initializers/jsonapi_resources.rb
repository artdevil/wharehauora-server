# frozen_string_literal: true

JSONAPI.configure do |config|
  # built in paginators are :none, :offset, :paged
  config.default_paginator = :offset
  config.default_page_size = 10
  config.maximum_page_size = 20
end

module JSONAPI
  class LinkBuilder
    private

    def formatted_module_path_from_class(klass)
      scopes = module_scopes_from_class(klass)

      unless scopes.empty?
        # The Main Hack: adding the #gsub
        "/#{ scopes.map(&:underscore).join('/') }/".gsub(/v1\//, '')
      else
        "/"
      end
    end

  end
end
