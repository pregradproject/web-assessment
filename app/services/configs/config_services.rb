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

  def frontend_config_groups_direct
    cache_key = self.class.send(:build_cache_key, 'frontend_groups')

    # Try cache first
    cached_groups = Rails.cache.read(cache_key)
    return cached_groups if cached_groups.present?

    # Build grouped configuration
    groups = {
      pricing: {
        vark_price: self.class.vark_price,
        ai_knowledge_price: self.class.ai_knowledge_price,
        behavioral_learning_price: self.class.behavioral_learning_price,
        comprehensive_assessment_price: self.class.comprehensive_assessment_price,
        tpa_price: self.class.tpa_price
      },
      tpa: {
        score_levels: self.class.tpa_score_levels
      }
    }

    # Cache for 15 minutes
    Rails.cache.write(cache_key, groups, expires_in: 15.minutes)

    groups
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

    def tpa_price
      get('tpa_price', 50000).to_i
    end

    def tpa_score_levels
      get_tpa_score_levels
    end

    def frontend_config_groups
      service_instance = new(nil)
      service_instance.frontend_config_groups_direct
    end

    def all_frontend_configs
      service_instance = new
      service_instance.instance_variable_set(:@key, nil)
      service_instance.send(:all_frontend_configs)
    end

    private

    def normalize_key(key)
      key.to_s.strip.downcase
    end

    def build_cache_key(key)
      "#{CACHE_NAMESPACE}:#{key}"
    end

    def get_tpa_score_levels
      # Get score levels from config or use defaults
      levels_json = get('tpa_score_levels', nil)

      if levels_json.present?
        begin
          JSON.parse(levels_json)
        rescue JSON::ParserError
          default_tpa_score_levels
        end
      else
        default_tpa_score_levels
      end
    end

    def set_tpa_score_levels(levels)
      levels_json = levels.to_json
      set('tpa_score_levels', levels_json,
          description: 'TPA score level configuration',
          value_type: 'string')
    end

    def default_tpa_score_levels
      {
        'low' => {
          'name' => 'Kategori Rendah',
          'min_score' => 200,
          'max_score' => 449,
          'label' => 'Kategori Rendah',
          'message' => 'Performa rendah, perlu bimbingan dan persiapan lebih intensif'
        },
        'average' => {
          'name' => 'Kategori Rata-Rata',
          'min_score' => 450,
          'max_score' => 549,
          'label' => 'Kategori Rata-Rata',
          'message' => 'Performa rata-rata, masih ada ruang untuk peningkatan'
        },
        'high' => {
          'name' => 'Kategori Tinggi',
          'min_score' => 550,
          'max_score' => 800,
          'label' => 'Kategori Tinggi',
          'message' => 'Performa tinggi, potensi akademik yang baik'
        }
      }
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
