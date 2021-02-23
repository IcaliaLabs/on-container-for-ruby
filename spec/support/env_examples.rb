# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:each, type: :env_spec) do |example|
    keys_before_example = ENV.keys + %w[LINES COLUMNS]

    example_env_vars = {}
    if example.example_group_instance.respond_to?(:example_env_vars)
      example_env_vars = example.example_group_instance.example_env_vars
    end
    
    ClimateControl.modify(example_env_vars) { example.run }
    
    (ENV.keys - keys_before_example).each { |added_key| ENV.delete added_key }
  end
end
