class SampleJob < ApplicationJob
  queue_as :default

  def perform(message)
    Rails.logger.info "SampleJob executed with message: #{message}"
    sleep(1) # Simulate work
    Rails.logger.info 'SampleJob completed'
  end
end
