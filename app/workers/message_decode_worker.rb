##
# class for decoding message income from sensor

class MessageDecodeWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'message_decode'

  def perform(topic, message)
    begin
      Message.new.decode(topic, message)
    rescue ActiveRecord::RecordNotFound => e
      # we only retry message unless not found error
      puts e.message
    end
  end
end
