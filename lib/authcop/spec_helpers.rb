module AuthCop::SpecHelpers
  def auth_scope_unsafe
    around(:each) do |example|
      AuthCop.unsafe { example.run }
    end
  end

  def auth_scope(name, &block)
    let!(name) do
      model = AuthCop.unsafe { self.instance_eval(&block) }
      AuthCop.push_scope model
      model
    end
    after(:each) { AuthCop.pop_scope }
  end
end
