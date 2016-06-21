require "celluloid/fiber"

module Celluloid
  class Thread < ::Thread
    def celluloid?
      true
    end
    
    #de DEPRECATE: Remove second behavior set, for before 2.3.1 compatibility:
    class << self
      if Thread.method_defined? :thread_variable_get
        def [](k)
          print "&"
          Thread.current.thread_variable_get(k)
        end
        def []=(k,v)
          print "%"
          Thread.current.thread_variable_set(k,v)
        end
      end
    end

    attr_accessor :busy

    # Obtain the role of this thread
    def role
      self[:celluloid_role]
    end

    def role=(role)
      self[:celluloid_role] = role
    end

    # Obtain the Celluloid::Actor object for this thread
    def actor
      self[:celluloid_actor]
    end

    # Obtain the Celluloid task object for this thread
    def task
      self[:celluloid_task]
    end

    # Obtain the Celluloid mailbox for this thread
    def mailbox
      self[:celluloid_mailbox]
    end

    # Obtain the call chain ID for this thread
    def call_chain_id
      self[:celluloid_chain_id]
    end

    def <<(proc)
      self[:celluloid_queue] << proc
      self
    end
  end
end
