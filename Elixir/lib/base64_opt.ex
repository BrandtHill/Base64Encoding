defmodule Base64Opt do
  @moduledoc """
  Brandt's Base64 Encoding implementation in Elixir
  """

  import Bitwise

  @table_charlist ~c"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

  @index_table @table_charlist
               |> Enum.map(&<<&1>>)
               |> List.to_tuple()

  @rev_table @table_charlist
             |> Enum.with_index()
             |> Enum.reduce(Tuple.duplicate(:whoops, 128), fn {char, index}, tup ->
               put_elem(tup, char, index)
             end)

  def indx(i), do: elem(@index_table, i)
  def rev(c), do: elem(@rev_table, c)

  def encode(data), do: encode(<<>>, data)

  defp encode(h, <<a::8, b::8, c::8, t::binary>>) do
    (h <>
       indx(a >>> 2) <>
       indx((a &&& 0x03) <<< 4 ||| b >>> 4) <>
       indx((b &&& 0x0F) <<< 2 ||| c >>> 6) <>
       indx(c &&& 0x3F))
    |> encode(t)
  end

  defp encode(h, <<>>), do: h
  defp encode(h, <<a::8>>), do: h <> indx(a >>> 2) <> indx((a &&& 0x03) <<< 4) <> "=="

  defp encode(h, <<a::8, b::8>>),
    do:
      h <>
        indx(a >>> 2) <> indx((a &&& 0x03) <<< 4 ||| b >>> 4) <> indx((b &&& 0x0F) <<< 2) <> "="

  def decode(data), do: decode(<<>>, data)

  defp decode(h, <<a, b, c, d, t::binary>>) when c != ?= and d != ?= do
    (h <>
       <<
         rev(a) <<< 2 ||| rev(b) >>> 4,
         (rev(b) <<< 4 &&& 0xF0) ||| (rev(c) >>> 2 &&& 0x0F),
         (rev(c) <<< 6 &&& 0xC0) ||| (rev(d) &&& 0x3F)
       >>)
    |> decode(t)
  end

  defp decode(h, <<>>), do: h
  defp decode(h, <<a, b, ?=, ?=>>), do: h <> <<rev(a) <<< 2 ||| rev(b) >>> 4>>

  defp decode(h, <<a, b, c, ?=>>),
    do:
      h <> <<rev(a) <<< 2 ||| rev(b) >>> 4, (rev(b) <<< 4 &&& 0xF0) ||| (rev(c) >>> 2 &&& 0x0F)>>
end
