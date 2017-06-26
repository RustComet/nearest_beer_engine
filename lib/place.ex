defmodule NearestBeerEngine.Place do
  defstruct name: nil, place_id: nil, address: nil, error: nil

  alias NearestBeerEngine.Place

  def init(%{"error" => error}) do
    %Place{error: error}
  end
  def init(%{"name" => name, "vicinity" => vicinity, "place_id" => place_id}) do
    %Place{name: name, address: vicinity, place_id: place_id}
  end

  def name(place) do
    {:ok, place.name}
  end
end
