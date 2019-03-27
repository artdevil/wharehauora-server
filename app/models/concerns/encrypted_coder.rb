##
# class for serialize encyrpt/decrypt input
class EncryptedCoder
  def load(value)
    return unless value.present?
    Marshal.load(
      Protected.decrypt(
        Base64.decode64(value)
      )
    )
  end

  def dump(value)
    Base64.encode64(
      Protected.encrypt(
        Marshal.dump(value)
      )
    )
  end
end