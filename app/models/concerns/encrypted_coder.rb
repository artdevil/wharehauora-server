##
# class for serialize encyrpt/decrypt input
class EncryptedCoder
  def load(value)
    return if value.blank?
    Protected.decrypt(
      Base64.decode64(value)
    )
  end

  def dump(value)
    Base64.encode64(
      Protected.encrypt(value)
    )
  end
end