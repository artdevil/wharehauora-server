# frozen_string_literal: true

class ApiConstraint
  attr_reader :version, :default

  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(request)
    @default || req.headers['Accept'].include?("version=#{version}")
  end
end