class Bubbles::PublishesController < ApplicationController
  include BubbleScoped, BucketScoped

  def create
    @bubble.published!
    redirect_to @bubble
  end
end
