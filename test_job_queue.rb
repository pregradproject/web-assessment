# Queue a test job
order = Order.where(testable_type: "VarkTest").first
order.update!(certificate_status: :not_generated)
puts "Queueing job for order: #{order.order_number}"
Certificates::GenerateJob.perform_later(order.id)
puts "Job queued. Current job count: #{SolidQueue::Job.count}"
puts "Current ready executions: #{SolidQueue::ReadyExecution.count}"
puts "Waiting 3 seconds for processing..."
sleep(3)
order.reload
puts "Final status: #{order.certificate_status}"
puts "Jobs remaining: #{SolidQueue::Job.count}"