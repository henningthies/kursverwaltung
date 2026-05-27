ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/auth_test_helper"

# Minimaler Stub-Helfer (Minitest 6 entfernt Object#stub). Ersetzt eine Methode für die
# Dauer des Blocks; val_or_callable kann ein Rückgabewert oder ein aufrufbares Objekt sein.
class Object
  def stub(name, val_or_callable, &block)
    original = method(name)
    singleton_class.send(:define_method, name) do |*args, **kwargs|
      val_or_callable.respond_to?(:call) ? val_or_callable.call(*args, **kwargs) : val_or_callable
    end
    block.call
  ensure
    singleton_class.send(:define_method, name) { |*a, **k| original.call(*a, **k) }
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
