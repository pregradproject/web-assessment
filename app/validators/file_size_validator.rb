# app/validators/file_size_validator.rb
class FileSizeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.respond_to?(:size)
    max_size = options[:less_than]
    if value.size > max_size
      record.errors.add(attribute, "must be smaller than #{max_size / 1.megabyte} MB")
    end
  end
end
