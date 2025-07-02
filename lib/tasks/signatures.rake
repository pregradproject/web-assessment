namespace :signatures do
  desc 'Create a test signature with a sample image'
  task create_test: :environment do
    # Create a test signature if none exists
    if Signature.active.empty?
      signature = Signature.create!(
        name: 'Dr. Jane Smith',
        department: 'Director of Learning Sciences',
        status: :active
      )

      puts "Created test signature: #{signature.name}"
      puts 'To add a signature image, use the admin interface at /admin/signatures'
    else
      puts 'Active signature already exists'
    end
  end

  desc 'List all signatures'
  task list: :environment do
    Signature.all.each do |sig|
      image_status = sig.signature_image.attached? ? '✓ Image attached' : '✗ No image'
      puts "#{sig.name} (#{sig.department}) - #{sig.status} - #{image_status}"
    end
  end
end
