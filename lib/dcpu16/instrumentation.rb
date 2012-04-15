require 'observer'

module DCPU16

  module Instrumentation

    module Observer

      def update(*args)
        method = args.shift
        __send__(method, *args) if respond_to?(method)
      end

    end

    include Observable

    def fire_callback(event, *args)
      changed(true)
      notify_observers(*args.unshift(event))
    end

  end

end