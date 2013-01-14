module AuthCop::SpecHelpers
  def auth_scope_unsafe
    around(:each) do |example|
      AuthCop.unsafe { example.run }
    end
  end

  def auth_scope(name)
    let!(name) { AuthCop.unsafe { yield } }

    around(:each) do |example|
      model = send(name)
      begin
        model.as_auth_scope { example.run }
      ensure
        AuthCop.unsafe { model.destroy rescue nil }
      end
    end
  end
end
