require 'nio'
require 'tamashii/agent/common'

module Tamashii
  module Agent
    class Component
      include Common::Loggable

      def initialize
        @pipe_r, @pipe_w = IO.pipe
      end

      def send_event(type, body)
        str = [type, body.bytesize].pack("Cn") + body
        @pipe_w.write(str)
      end

      def receive_event
        ev_type, ev_size = @pipe_r.read(3).unpack("Cn")
        ev_body = @pipe_r.read(ev_size)
        process_event(ev_type, ev_body)
      end

      def process_event(ev_type, ev_body)
        logger.debug "Got event: #{ev_type}, #{ev_body}"
      end

      # worker
      def run
        @thr = Thread.start { run_worker_loop }
      end

      def run!
        run_worker_loop
      end
      
      def stop
        logger.info "Stopping component"
        @thr.exit if @thr
        @thr = nil
        clean_up
      end

      def clean_up
      end

      def run_worker_loop
        create_selector
        register_event_io
        worker_loop
      end

      # a default implementation
      def worker_loop
        loop do
          ready = @selector.select
          ready.each { |m| m.value.call } if ready
        end
      end
      
      def register_event_io
        _monitor = @selector.register(@pipe_r, :r)
        _monitor.value = method(:receive_event)
      end

      def create_selector
        @selector = NIO::Selector.new
      end
    end
  end
end
