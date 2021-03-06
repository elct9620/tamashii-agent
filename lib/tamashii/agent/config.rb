require 'tamashii/common'
module Tamashii
  module Agent
    class Config < Tamashii::Config
      AUTH_TYPES = [:none, :token]

      register :log_file, STDOUT
      register :use_ssl, false
      register :auth_type, :none
      register :entry_point, "/tamashii"
      register :manager_host, "localhost"
      register :manager_port, 3000

      def auth_type(type = nil)
        return @auth_type ||= :none if type.nil?
        return unless AUTH_TYPES.include?(type)
        @auth_type = type.to_sym
      end

      def log_level(level = nil)
        return Agent.logger.level if level.nil?
        Agent.logger.level = level
      end
    end
  end
end
