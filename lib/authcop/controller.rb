module AuthCop::Controller
  def auth_scope_unsafe
    AuthCop.unsafe { yield }
  end
end
