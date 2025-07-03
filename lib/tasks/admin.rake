namespace :admin do
  desc 'Create an admin user'
  task create_user: :environment do
    email = ENV['ADMIN_EMAIL'] || 'admin@cakravia.com'
    password = ENV['ADMIN_PASSWORD'] || 'password'

    admin = AdminUser.find_or_initialize_by(email: email)

    if admin.persisted?
      puts "Admin user already exists with email: #{email}"
      if ENV['ADMIN_PASSWORD']
        admin.password = password
        admin.password_confirmation = password
        admin.save!
        puts "Password updated for admin user: #{email}"
      end
    else
      admin.password = password
      admin.password_confirmation = password
      admin.save!
      puts 'Created admin user:'
    end

    puts "Email: #{email}"
    puts "Password: #{password}"
    puts 'Login at: /admin'
  end

  desc 'List all admin users'
  task list: :environment do
    puts 'Admin Users:'
    AdminUser.all.each do |admin|
      puts "- #{admin.email} (created: #{admin.created_at.strftime('%Y-%m-%d %H:%M:%S')})"
    end
  end
end
