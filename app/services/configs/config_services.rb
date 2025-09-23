module Configs
  class ConfigServices < ApplicationService
  CACHE_NAMESPACE = 'configs'
  CACHE_EXPIRY = 1.hour

  def initialize(key, value = nil, description = nil, value_type = 'string')
    @key = key
    @value = value
    @description = description
    @value_type = value_type
  end

  def call
    case @value
    when nil
      get_config
    else
      set_config
    end
  end

  class << self
    def get(key, default_value = nil)
      new(key).call || default_value
    end

    def set(key, value, description: nil, value_type: 'string')
      new(key, value, description, value_type).call
    end

    def clear_cache(key = nil)
      if key
        normalized_key = normalize_key(key)
        cache_key = build_cache_key(normalized_key)
        Rails.cache.delete(cache_key)
      else
        Rails.cache.delete_matched("#{CACHE_NAMESPACE}:*")
      end
    end

    def vark_price
      get('vark_price', 30000).to_i
    end

    def ai_knowledge_price
      get('ai_knowledge_price', 35000).to_i
    end

    def behavioral_learning_price
      get('behavioral_learning_price', 40000).to_i
    end

    def comprehensive_assessment_price
      get('comprehensive_assessment_price', 45000).to_i
    end

    private

    def normalize_key(key)
      key.to_s.strip.downcase
    end

    def build_cache_key(key)
      "#{CACHE_NAMESPACE}:#{key}"
    end
  end

  private

  def get_config
    normalized_key = self.class.send(:normalize_key, @key)
    cache_key = self.class.send(:build_cache_key, normalized_key)

    # Try cache first
    cached_value = Rails.cache.read(cache_key)
    return cached_value unless cached_value.nil?

    # Get from database
    config_record = Config.find_by(key: normalized_key)

    if config_record
      typed_value = config_record.typed_value
      Rails.cache.write(cache_key, typed_value, expires_in: CACHE_EXPIRY)
      typed_value
    end
  end

  def set_config
    normalized_key = self.class.send(:normalize_key, @key)

    config_record = Config.find_or_initialize_by(key: normalized_key)
    config_record.assign_attributes(
      value: @value.to_s,
      description: @description,
      value_type: @value_type
    )

    if config_record.save
      self.class.clear_cache(normalized_key)
      config_record.typed_value
    else
      raise ActiveRecord::RecordInvalid, config_record
    end
  end
  end
end
