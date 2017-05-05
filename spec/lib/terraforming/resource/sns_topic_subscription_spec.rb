require "spec_helper"

module Terraforming
  module Resource
    describe SNSTopicSubscription do
      let(:client) do
        Aws::SNS::Client.new(stub_responses: true)
      end

      let(:subscriptions) do
        [
            Aws::SNS::Types::Subscription.new(subscription_arn: "arn:aws:sns:us-west-2:012345678901:a-cool-topic:000ff1ce-dead-beef-f00d-ea7food5a1d1"),
        ]
      end

      let(:attributes) do
        {
          "Endpoint"                     => "arn:aws:sqs:us-west-2:012345678901:a-cool-queue",
          "Protocol"                     => "sqs",
          "RawMessageDelivery"           => "false",
          "ConfirmationWasAuthenticated" => "true",
          "Owner"                        => "012345678901",
          "SubscriptionArn"              => "arn:aws:sns:us-west-2:012345678901:a-cool-topic:000ff1ce-dead-beef-f00d-ea7food5a1d1",
          "TopicArn"                     => "arn:aws:sns:us-west-2:012345678901:a-cool-topic"
        }
      end

      before do
        client.stub_responses(:list_subscriptions, subscriptions: subscriptions)
        client.stub_responses(:get_subscription_attributes, attributes: attributes)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_sns_topic_subscription" "000ff1ce-dead-beef-f00d-ea7food5a1d1" {
  topic_arn            = "arn:aws:sns:us-west-2:012345678901:a-cool-topic"
  protocol             = "sqs"
  endpoint             = "arn:aws:sqs:us-west-2:012345678901:a-cool-queue"
  raw_message_delivery = "false"
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_sns_topic_subscription.000ff1ce-dead-beef-f00d-ea7food5a1d1" => {
              "type" => "aws_sns_topic_subscription",
              "primary" => {
                "id" => "arn:aws:sns:us-west-2:012345678901:a-cool-topic:000ff1ce-dead-beef-f00d-ea7food5a1d1",
                "attributes" => {
                  "id"                   => "arn:aws:sns:us-west-2:012345678901:a-cool-topic:000ff1ce-dead-beef-f00d-ea7food5a1d1",
                  "topic_arn"            => "arn:aws:sns:us-west-2:012345678901:a-cool-topic",
                  "protocol"             => "sqs",
                  "endpoint"             => "arn:aws:sqs:us-west-2:012345678901:a-cool-queue",
                  "raw_message_delivery" => "false"
                },
              },
            }
          })
        end
      end
    end
  end
end
