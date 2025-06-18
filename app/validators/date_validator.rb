
class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    date = parse_date(value)
    return add_invalid_date_error(record, attribute) unless date

    validate_date_constraints(record, attribute, date)
  end

  private

  def parse_date(value)
    value.to_date
  rescue ArgumentError, TypeError
    nil
  end

  def add_invalid_date_error(record, attribute)
    record.errors.add(attribute, options[:message] || 'is not a valid date')
  end

  def validate_date_constraints(record, attribute, date)
    validate_before_constraint(record, attribute, date)
    validate_after_constraint(record, attribute, date)
  end

  def validate_before_constraint(record, attribute, date)
    return unless options[:before]

    comparison_date = options[:before].respond_to?(:call) ? options[:before].call : options[:before]
    if !(date < comparison_date)
      record.errors.add(attribute, options[:message] || "must be before #{comparison_date}")
    end
  end

  def validate_after_constraint(record, attribute, date)
    return unless options[:after]

    comparison_date = options[:after].respond_to?(:call) ? options[:after].call : options[:after]
    if !(date > comparison_date)
      record.errors.add(attribute, options[:message] || "must be after #{comparison_date}")
    end
  end
end
