defmodule NearestBeerEngine.Query do
  defstruct address: :none, venue_type: :none

  use HTTPoison.Base
  alias NearestBeerEngine.{Query, GooglePlaces, Place}

  @api_key Application.get_env(:nearest_beer_engine, :api_key) || System.get_env("GOOGLE_API_KEY")
  @spot_search "/nearbysearch/json?key=#{@api_key}"

  def process_url(url) do
    "https://maps.googleapis.com/maps/api/place" <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
  end

  def find_nearest(%{"address" => "", "venue_type" => venue_type}) do
    Place.init(%{"error" => "We can't find beer until we know where you are. Please enter a valid address"})
  end
  def find_nearest(%{"address" => address, "venue_type" => venue_type}) do
    get_coordinates(address)
    |> nearby_search(venue_type)
    |> parse_results
    |> create_place
  end

  def get_coordinates(address) do
    GooglePlaces.latlon(address)
  end

  def nearby_search(coordinates, venue_type) do
    case get(@spot_search <> "&rankby=distance&opennow&keyword=beer&location=" <> coordinates <> "&type=" <> venue_type) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: status}} ->
        {:error, "Oops. Looks like there's nothing open nearby"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def parse_results({:ok, results}) do
    results
    |> Map.get("results")
    |> List.first
  end
  def parse_results({:error, message}) do
    {:error, "Looks like we couldn't find any beer nearby"}
  end

  def create_place(nil) do
    Place.init(%{"error" => "We couldn't find any beer nearby… Sorry"})
  end
  def create_place(attributes) do
    Place.init(attributes)
  end
end
