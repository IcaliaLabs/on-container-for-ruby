# frozen_string_literal: true

require 'socket'
require 'timeout'
require 'uri'

module OnContainer
  module Ops
    module ServiceConnectionChecks
      def service_accepts_connections?(service_uri, seconds_to_wait = 30)
        uri = URI(service_uri)

        Timeout::timeout(seconds_to_wait) do
          TCPSocket.new(uri.host, uri.port).close
        rescue Errno::ECONNREFUSED
          retry
        end

        true

      rescue => e
        puts "Connection to #{uri.to_s} failed: '#{e.inspect}'"
      end
      
      def wait_for_service_to_accept_connections(service_uri, seconds_to_wait = 30, exit_on_fail = true)
        wait_loop = Thread.new do
          loop do
            sleep(5)
            puts "Waiting for #{service_uri} to accept connections..."
          end
        end

        if service_accepts_connections?(service_uri, seconds_to_wait)
          return wait_loop.exit
        else
          exit 1 if exit_on_fail
        end
      end
    end
  end
end
