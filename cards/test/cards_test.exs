defmodule CardsTest do
  use ExUnit.Case
  doctest Cards

  test "create_deck makes 52 cards" do
    assert length(Cards.create_deck) == 52
  end

  test "shuffling a deck randomises it" do
    deck = Cards.create_deck
    shuffled_deck = Cards.shuffle(deck)
    refute deck == shuffled_deck
  end
end
