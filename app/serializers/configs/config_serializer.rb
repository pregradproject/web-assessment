module Configs
  class ConfigSerializer < ApplicationSerializer
    attributes :key, :value, :value_type

    attribute :value do |object|
      object.typed_value
    end
  end
end
