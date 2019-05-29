defmodule Base64 do
  @moduledoc """
  Brandt's Base64 Encoding implementation in Elixir
  """

use Bitwise, only_operators: true

  def encode(data), do: encode(<<>>, data)
  defp encode(h, <<>>), do: h
  defp encode(h, <<a::8>>), do: h <> indx(a >>> 2) <> indx((a &&& 0x03) <<< 4) <> "=="
  defp encode(h, <<a::8, b::8>>), do: h <> indx(a >>> 2) <> indx((a &&& 0x03) <<< 4 ||| b >>> 4) <> indx((b &&& 0x0F) <<< 2) <> "="
  defp encode(h, <<a::8, b::8, c::8, t::binary>>) do
    h
    <> indx(a >>> 2)
    <> indx((a &&& 0x03) <<< 4 ||| b >>> 4)
    <> indx((b &&& 0x0F) <<< 2 ||| c >>> 6)
    <> indx(c &&& 0x3F)
    |> encode(t)
  end

  def decode(data), do: decode(<<>>, data)
  defp decode(h, <<>>), do: h
  defp decode(h, <<a, b, ?=, ?=>>), do: h <> <<rev(a) <<< 2 ||| rev(b) >>> 4>>
  defp decode(h, <<a, b, c, ?=>>), do: h <> <<rev(a) <<< 2 ||| rev(b) >>> 4, rev(b) <<< 4 &&& 0xF0 ||| rev(c) >>> 2 &&& 0x0F>>
  defp decode(h, <<a, b, c, d, t::binary>>) do 
    h <>
    <<
      rev(a) <<< 2 ||| rev(b) >>> 4,
      rev(b) <<< 4 &&& 0xF0 ||| rev(c) >>> 2 &&& 0x0F,
      rev(c) <<< 6 &&& 0xC0 ||| rev(d) &&& 0x3F
    >>
    |> decode(t)
  end

  defp indx(i) do
    cond do
      i < 26 -> <<i + 65>> #A-Z
      i < 52 -> <<i + 71>> #a-z
      i < 62 -> <<i - 04>> #0-9
      i == 62 -> "+"
      i == 63 -> "/"
    end
  end

  defp rev(i) do
    cond do
      i > 96 -> i - 71 #A-Z
      i > 64 -> i - 65 #a-z
      i > 47 -> i + 04 #0-9
      i == ?/ -> 63
      i == ?+ -> 62
    end
  end
end
