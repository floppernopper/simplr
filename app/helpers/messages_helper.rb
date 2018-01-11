module MessagesHelper
  def decrypt_message message
    key = message.user.unique_token
    if key and message.salt
		  key = ActiveSupport::KeyGenerator.new(key).generate_key(message.salt)
		  encryptor = ActiveSupport::MessageEncryptor.new(key)
      message = encryptor.decrypt_and_verify(message.body)
      return message
    else
      return message.body
    end
  end
end
