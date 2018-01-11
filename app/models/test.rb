# used for testing as well as running certain tasks in production like updating records

class Test < ApplicationRecord
  def self.update_unique_msgs
    for message in Message.all
      message.update unique_token: SecureRandom.urlsafe_base64
    end
  end
  
  def self.char_bits items
    bits = []; for item in items
      for char in (item.body.present? ? item.body : item.image.to_s).split("")
        for bit in ("%04b" % char.codepoints.first).split("")
          bits << bit.to_i
        end
      end
    end
    return bits
  end
end
