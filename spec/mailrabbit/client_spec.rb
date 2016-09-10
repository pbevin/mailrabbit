require "spec_helper"
require "bunny"

describe Mailrabbit::Client do
  let(:exchange) { instance_double(Bunny::Exchange) }
  let(:client) { Mailrabbit::Client.new(exchange: exchange) }

  specify "add_member" do
    expect(exchange)
      .to receive(:publish)
      .with("add_member mylist test@example.com full", persistent: true)

    client.add_member(
      list: "mylist",
      email: "test@example.com",
      delivery: Mailrabbit::DELIVER_FULL
    )
  end

  specify "remove_member" do
    expect(exchange)
      .to receive(:publish)
      .with("remove_member mylist test@example.com", persistent: true)

    client.remove_member(
      list: "mylist",
      email: "test@example.com"
    )
  end

  specify "change_email" do
    expect(exchange)
      .to receive(:publish)
      .with("change_email mylist test@example.com new@example.com", persistent: true)

    client.change_email(
      list: "mylist",
      old_email: "test@example.com",
      new_email: "new@example.com"
    )
  end

  specify "change_delivery" do
    expect(exchange)
      .to receive(:publish)
      .with("change_delivery mylist test@example.com digest", persistent: true)

    client.change_delivery(
      list: "mylist",
      email: "test@example.com",
      delivery: Mailrabbit::DELIVER_DIGEST
    )
  end
end
