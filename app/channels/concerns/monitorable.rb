# monitors connection status and disconnects if it is dropped for some reason
# See https://wowinter13.medium.com/actioncable-handling-client-connection-errors-on-server-side-93ea74178d03
module Monitorable
  extend ActiveSupport::Concern

  included do
    after_subscribe :connection_monitor

    CONNECTION_TIMEOUT = 10.seconds
    CONNECTION_PING_INTERVAL = 5.seconds

    periodically every: CONNECTION_PING_INTERVAL do
      @driver&.ping
      if Time.now - @_last_request_at > @_timeout
        connection.disconnect
      end
    end

    def connection_monitor
      @_last_request_at ||= Time.now
      @_timeout = CONNECTION_TIMEOUT      
      @driver = connection.instance_variable_get('@websocket').possible?&.instance_variable_get('@driver')
      @driver.on(:pong) { @_last_request_at = Time.now }
    end
  end
end