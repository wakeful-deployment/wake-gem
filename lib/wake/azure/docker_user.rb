class DockerUser
  attr_reader :username, :password, :email

  def initialize(username:, password:, email:)
    @username = username
    @password = password
    @email    = email
  end
end
