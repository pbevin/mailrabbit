require "anima"

module Mailrabbit
  class Client
    include Anima.new(:exchange)

    def add_member(list:, email:, delivery:)
      publish("add_member", list, email, delivery)
      self
    end

    def remove_member(list:, email:)
      publish("remove_member", list, email)
      self
    end

    def change_email(list:, old_email:, new_email:)
      publish("change_email", list, old_email, new_email)
      self
    end

    def change_delivery(list:, email:, delivery:)
      publish("change_delivery", list, email, delivery)
      self
    end

    private

    def publish(*args)
      message = args.join(" ")
      exchange.publish(message, persistent: true)
    end
  end
end
