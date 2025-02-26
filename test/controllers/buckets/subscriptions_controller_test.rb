require "test_helper"

class Buckets::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as :jz
  end

  test "subscribing to a bucket" do
    assert_changes -> { buckets(:writebook).subscribed_by?(users(:jz)) }, from: false, to: true do
      put bucket_subscriptions_url(buckets(:writebook)), params: { subscribed: "1" }
    end

    assert_response :success
  end

  test "unsubscribing from a bucket" do
    buckets(:writebook).subscribe(users(:jz))

    assert_changes -> { buckets(:writebook).subscribed_by?(users(:jz)) }, from: true, to: false do
      put bucket_subscriptions_url(buckets(:writebook))
    end

    assert_response :success
  end
end
