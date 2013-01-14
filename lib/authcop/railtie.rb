require 'rails'

class AuthCop::Railtie < Rails::Railtie
  railtie_name :authcop

  initializer "authcopy.active_record" do
    ActiveRecord::Base.send :extend, AuthCop
  end

  initializer "authcopy.warden" do
    if defined?(Warden)
      Warden::Manager.after_set_user do |user, auth, opts|
        Thread.current[:auth_scope_warden_pushed] = true
        AuthCop.push_scope(user)
      end
    end
  end

  initializer "authcopy.controller" do
    ActionController::Base.send :include, AuthCop::Controller

    ActionController::Base.after_filter do
      if Thread.current[:auth_scope_warden_pushed]
        AuthCop.pop_scope
        Thread.current[:auth_scope_warden_pushed] = nil
      end
    end
  end

  config.to_prepare do
    if defined?(Devise)
      Devise::ConfirmationsController.around_filter :auth_scope_unsafe, :only => [:new, :create, :show]
      Devise::PasswordsController.around_filter :auth_scope_unsafe, :only => [:new, :create]
      Devise::RegistrationsController.around_filter :auth_scope_unsafe, :only => [:new, :create]
      Devise::SessionsController.around_filter :auth_scope_unsafe, :only => [:new, :destroy]
    end
  end

  console do
    AuthCop.unsafe!
  end
end