module Users
  class UserSerializer < ApplicationSerializer
    attributes(
      :id,
      :name,
      :email,
      :phone,
      :birthday,
      :avatar_url,
      :updated_at
    )
  end
end
