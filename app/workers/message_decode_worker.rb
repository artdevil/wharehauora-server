##
# class for decoding message income from sensor

class MessageDecodeWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'message_decode'

  def perform(topic, message)
    Message.new.decode(topic, message)
  rescue ActiveRecord::RecordNotFound => e
    # we only retry message unless not found error
    logger.info(e.message)
  end
end
