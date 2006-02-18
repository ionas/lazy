# = lazy/async.rb -- asynchronous computations, based on promises
#
# Author:: MenTaLguY
#
# Copyright 2006  MenTaLguY <mental@rydia.net>
#
# You may redistribute it and/or modify it under the same terms as Ruby.
#

require 'lazy/threadsafe'

module Lazy

class Async < Promise
  def initialize( &computation ) #:nodoc:
    result = nil
    exception = nil

    thread = Thread.new do
      begin
        result = computation.call( self )
      rescue Exception => exception
      end
    end

    super() do
      raise DivergenceError.new if Thread.current == thread
      thread.join
      raise exception if exception
      result
    end
  end
end

end

module Kernel

# Schedules a computation to be run asynchronously in a background thread
# and returns a promise for its result.  Kernel.demand will wait for the
# computation to finish.
#
# As with Kernel.promise, async passes the block a promise for its own
# result -- use wisely.
#
def async( &computation ) #:yields: result
  Lazy::Async.new &computation
end 

end

