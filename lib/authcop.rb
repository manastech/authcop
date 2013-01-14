module AuthCop
  def self.unsafe
    Thread.current[:auth_scope_unsafe] ||= 0
    Thread.current[:auth_scope_unsafe] += 1
    yield
  ensure
    Thread.current[:auth_scope_unsafe] -= 1
  end

  def self.unsafe?
    unsafe = Thread.current[:auth_scope_unsafe]
    unsafe && unsafe > 0
  end

  def self.unsafe!
    Thread.current[:auth_scope_unsafe] = 1
  end

  def self.with_auth_scope(object)
    if object
      object.as_auth_scope { yield }
    else
      yield
    end
  end

  def self.push_scope(scope)
    Thread.current[:auth_scope] ||= []
    Thread.current[:auth_scope].push scope
  end

  def self.pop_scope
    Thread.current[:auth_scope] && Thread.current[:auth_scope].pop
  end

  def self.current_scope
    Thread.current[:auth_scope] && Thread.current[:auth_scope].last
  end

  def defines_auth_scope
    define_method :as_auth_scope do |&block|
      begin
        AuthCop.push_scope self
        block.call
      ensure
        AuthCop.pop_scope
      end
    end

    class_eval %Q(
      def self.serialize_from_session(*)
        AuthCop.unsafe { super }
      end
    )
  end

  def auth_scope_for(model, &block)
    @auth_scope_procs ||= {}
    @auth_scope_procs[model.to_sym] = block
  end

  def inherited(child_class)
    super
    child_class.default_scope do
      if scope_model = AuthCop.current_scope
        scope_model_name = scope_model.class.name.gsub(/^.*::/, '').underscore.to_sym
        procs = child_class.instance_variable_get(:@auth_scope_procs)
        auth_scope_proc = procs && procs[scope_model_name]
        raise "#{child_class.name} must define auth_scope_for(:#{scope_model_name})" unless auth_scope_proc
        auth_scope_proc.call scope_model
      else
        raise "No auth scope defined" unless AuthCop.unsafe?
        child_class.scoped
      end
    end
  end
end

require "authcop/controller"
require "authcop/spec_helpers"
require "authcop/version"
require 'authcop/railtie' if defined?(Rails)

