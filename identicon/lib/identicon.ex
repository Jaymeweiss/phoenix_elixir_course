defmodule Identicon do
  @moduledoc """
  Documentation for `Identicon`.
  """

  alias Identicon.Image

  def main(input) do
    input
    |> hash_input
    |> determine_colour
    |> build_grid
    |> filter_out_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  defp hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Image{hex: hex}
  end
  
  defp determine_colour(%Image{hex: [r, g, b | _tail]} = image) do
    %Image{image | colour: {r, g, b}}
  end

  defp build_grid(%Image{hex: hex} = image) do
    grid = Enum.chunk_every(hex, 3, 3, :discard)
    |> Enum.map(&mirror_row/1)
    |> List.flatten
    |> Enum.with_index

    %Image{image | grid: grid}
  end

  defp mirror_row(row) do
   [first, second | _tail] = row
   row ++ [second, first]
  end

  defp filter_out_odd_squares(%Image{grid: grid} = image) do
    filtered_grid = grid
      |> Enum.filter(fn({value, _index}) -> rem(value, 2) == 0 end)

    %Image{image | grid: filtered_grid}
  end

  defp build_pixel_map(%Image{grid: grid} = image) do
    pixel_map = Enum.map(grid, fn({_value, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end)

    %Image{image | pixel_map: pixel_map}
  end

  defp draw_image(%Image{colour: colour, pixel_map: pixel_map}) do
    image_area = :egd.create(250, 250)
    fill = :egd.color(colour)
    Enum.each(pixel_map, fn({top_left, bottom_right}) ->
      :egd.filledRectangle(image_area, top_left, bottom_right, fill)
    end)

    :egd.render(image_area)
  end

  defp save_image(image, filename) do
    File.write("#{filename}.png", image)
  end

end
