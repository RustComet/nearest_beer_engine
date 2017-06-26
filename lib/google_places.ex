defmodule NearestBeerEngine.GooglePlaces do

  @moduledoc false
  # https://developers.google.com/places/web-service/?hl=ja

  use HTTPoison.Base

  #require Logger
  @api_key Application.get_env(:nearest_beer_engine, :api_key)
  @text_search "/json?key=#{@api_key}"

  def process_url(url) do
    "https://maps.googleapis.com/maps/api/geocode" <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
  end

  def text_search(text) do
    case get(@text_search <> "&address=" <> URI.encode(text)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, "error status : " <> to_string(body)}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def latlon("unit test") do
    "0.0,0.0"
  end

  def latlon(address) when is_binary(address) do
    latlng = address
    |> text_search
    |> google_latlng

    "#{latlng["lat"]},#{latlng["lng"]}"
  end

  def latlon(_) do
    "0.0,0.0"
  end

  defp google_latlng({:ok, result}) do
    result
    |> Map.get("results")
    |> hd
    |> Map.get("geometry")
    |> Map.get("location")
  end
end
