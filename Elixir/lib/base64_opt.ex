defmodule Base64Opt do
  @moduledoc """
  Brandt's Base64 Encoding implementation in Elixir
  """

  use Bitwise, only_operators: true

  @table 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

  def encode(data), do: encode(<<>>, data)
  defp encode(h, <<>>), do: h
  defp encode(h, <<a::8>>), do: h <> indx(a >>> 2) <> indx((a &&& 0x03) <<< 4) <> "=="
  defp encode(h, <<a::8, b::8>>), do: h <> indx(a >>> 2) <> indx((a &&& 0x03) <<< 4 ||| b >>> 4) <> indx((b &&& 0x0F) <<< 2) <> "="

  defp encode(h, <<a::8, b::8, c::8, t::binary>>) do
    (h <>
       indx(a >>> 2) <>
       indx((a &&& 0x03) <<< 4 ||| b >>> 4) <>
       indx((b &&& 0x0F) <<< 2 ||| c >>> 6) <>
       indx(c &&& 0x3F))
    |> encode(t)
  end

  def decode(data), do: decode(<<>>, data)
  defp decode(h, <<>>), do: h
  defp decode(h, <<a, b, ?=, ?=>>), do: h <> <<rev(a) <<< 2 ||| rev(b) >>> 4>>

  defp decode(h, <<a, b, c, ?=>>),
    do:
      h <> <<rev(a) <<< 2 ||| rev(b) >>> 4, (rev(b) <<< 4 &&& 0xF0) ||| (rev(c) >>> 2 &&& 0x0F)>>

  defp decode(h, <<a, b, c, d, t::binary>>) do
    (h <>
       <<
         rev(a) <<< 2 ||| rev(b) >>> 4,
         (rev(b) <<< 4 &&& 0xF0) ||| (rev(c) >>> 2 &&& 0x0F),
         (rev(c) <<< 6 &&& 0xC0) ||| (rev(d) &&& 0x3F)
       >>)
    |> decode(t)
  end

  for {val, i} <- Enum.with_index(@table) do
    def indx(unquote(i)), do: <<unquote(val)>>
    def rev(unquote(val)), do: unquote(i)
  end
end
