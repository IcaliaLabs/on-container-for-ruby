# frozen_string_literal: true

require 'socket'
require 'timeout'
require 'uri'

module OnContainer
  module Ops
    module ServiceConnection
      def service_accepts_connections?(service_uri, seconds_to_wait = 30)
        uri = URI(service_uri)

        Timeout::timeout(seconds_to_wait) do
          TCPSocket.new(uri.host, uri.port).close
        end

        true

      rescue => e
        puts "Connection to #{uri.to_s} failed: '#{e.inspect}'"
      end
      
      def wait_for_service_to_accept_connections(service_uri, seconds_to_wait = 30, exit_on_fail = true)
        return if service_accepts_connections?(service_uri, seconds_to_wait)
      
        exit 1 if exit_on_fail
      end
    end
  end
end