module Celluloid

  #de TODO: Take advantage of the rbx-3.40+ implementation of Fibers
  #de       just make Thread#[] and #[]= aliases for thread_local_get and _set respectively
  #de       ...create this alias if method_defined? on Thread has thread_local_get

  class Task
    # Tasks with a Fiber backend
    class Fibered < Task
      class StackError < Celluloid::Error; end
      #de DEPRECATE: Once 2.3.* support is the threshold, this can be only the first case.
      #de if Thread.method_defined? :thread_variable_get
        def create
          @fiber = Fiber.new do
            Thread[:celluloid_role] = :actor
            yield
          end
        end
      #de else
      #de   def create
      #de     queue = Thread[:celluloid_queue]
      #de     actor_system = Thread[:celluloid_actor_system]
      #de     @fiber = Fiber.new do
      #de       # FIXME: cannot use the writer as specs run inside normal Threads
      #de       Thread[:celluloid_role] = :actor
      #de       Thread[:celluloid_queue] = queue
      #de       Thread[:celluloid_actor_system] = actor_system
      #de       yield
      #de     end
      #de   end
      #de end

      def signal
        Fiber.yield
      end

      # Resume a suspended task, giving it a value to return if needed
      def deliver(value)
        @fiber.resume value
      rescue SystemStackError => ex
        raise StackError, "#{ex} @#{meta[:method_name] || :unknown} (see https://github.com/celluloid/celluloid/wiki/Fiber-stack-errors)"
      rescue FiberError => ex
        raise DeadTaskError, "cannot resume a dead task (#{ex})"
      end

      # Terminate this task
      def terminate
        super
      rescue FiberError
        # If we're getting this the task should already be dead
      end

      def backtrace
        ["#{self.class} backtrace unavailable. Please try `Celluloid.task_class = Celluloid::Task::Threaded` if you need backtraces here."]
      end
    end
  end
end
