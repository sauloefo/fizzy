class LandingsController < ApplicationController
  def show
    if Current.user.collections.many?
      redirect_to events_path
    else
      redirect_to collection_path(Current.user.collections.first)
    end
  end
end
