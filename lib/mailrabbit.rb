require "bunny"
require "mailrabbit/version"
require "mailrabbit/client"

module Mailrabbit
  Delivery = Struct.new(:name) do
    def to_s
      name
    end
  end

  DELIVER_FULL = Delivery.new("full")
  DELIVER_NONE = Delivery.new("none")
  DELIVER_DIGEST = Delivery.new("digest")

  module_function

  #
  # Mailrabbit.client("rabbitmq_hostname") do |client|
  #   client.add_member "listname", "test@example.com", Mailrabbit::DELIVER_FULL
  # end
  #
  def client(hostname=default_hostname)
    find_exchange(hostname) do |exchange, _channel|
      yield Client.new(exchange: exchange)
    end
  end

  def add_member(list:, email:, delivery:)
    client { |c| c.add_member(list: list, email: email, delivery: delivery) }
  end

  def remove_member(list:, email:)
    client { |c| c.remove_member(list: list, email: email) }
  end

  def change_email(list:, old_email:, new_email:)
    client { |c| c.change_email(list: list, old_email: email, new_email: new_email) }
  end

  def change_delivery(list:, email:, delivery:)
    client { |c| c.change_delivery(list: list, email: email, delivery: delivery) }
  end

  #
  # Mailrabbit.worker("rabbitmq_hostname") do |message|
  #   puts "Received #{message}"
  # end
  def worker(hostname, logger: NullLogger.new)
    find_exchange(hostname) do |exchange, channel|
      queue = channel.queue("worker")
      queue.bind(exchange)

      logger.info("Mailrabbit: connected to exchange #{exchange.name}")
      opts = { block: true, manual_ack: true }
      queue.subscribe(opts) do |delivery_info, _properties, payload|
        logger.info("Mailrabbit: received #{payload}")
        yield payload
        channel.ack(delivery_info.delivery_tag)
        logger.info("Mailrabbit: acknowledged #{payload}")
      end
    end
  end

  def find_exchange(hostname)
    conn = Bunny.new(hostname: hostname)
    conn.start
    channel = conn.create_channel
    exchange = channel.fanout("mailrabbit.subscribers")

    yield exchange, channel

  ensure
    conn.close if conn
  end

  def default_hostname=(val)
    @@default_hostname = val
  end

  def default_hostname
    @@default_hostname
  end

  class NullLogger
    def debug(*); end
    def info(*); end
    def warn(*); end
    def error(*); end
  end
end
