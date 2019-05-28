defmodule Base64 do
  @moduledoc """
  Brandt's Base64 Encoding implementation in Elixir
  """

  @index %{0=>"A",1=>"B",2=>"C",3=>"D",4=>"E",5=>"F",6=>"G",7=>"H",8=>"I",9=>"J",10=>"K",11=>"L",12=>"M",13=>"N",14=>"O",15=>"P",
16=>"Q",17=>"R",18=>"S",19=>"T",20=>"U",21=>"V",22=>"W",23=>"X",24=>"Y",25=>"Z",26=>"a",27=>"b",28=>"c",29=>"d",30=>"e",31=>"f",
32=>"g",33=>"h",34=>"i",35=>"j",36=>"k",37=>"l",38=>"m",39=>"n",40=>"o",41=>"p",42=>"q",43=>"r",44=>"s",45=>"t",46=>"u",47=>"v",
48=>"w",49=>"x",50=>"y",51=>"z",52=>"0",53=>"1",54=>"2",55=>"3",56=>"4",57=>"5",58=>"6",59=>"7",60=>"8",61=>"9",62=>"+",63=>"/"}

use Bitwise, only_operators: true

  def encode(data), do: encode(<<>>, data)
  defp encode(h, <<>>), do: h
  defp encode(h, <<a::8>>), do: h <> @index[a >>> 2] <> @index[(a &&& 0x03) <<< 4] <> "=="
  defp encode(h, <<a::8, b::8>>), do: h <> @index[a >>> 2] <> @index[(a &&& 0x03) <<< 4 ||| b >>> 4] <> @index[(b &&& 0x0F) <<< 2] <> "="
  defp encode(h, <<a::8, b::8, c::8, t::binary>>) do
    h
    <> @index[a >>> 2]
    <> @index[(a &&& 0x03) <<< 4 ||| b >>> 4]
    <> @index[(b &&& 0x0F) <<< 2 ||| c >>> 6]
    <> @index[c &&& 0x3F]
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

  defp rev(i) do
    cond do
      i > 0x60 -> i - 0x47
      i > 0x40 -> i - 0x41
      i > 0x2F -> i + 0x04
      true ->
        case i do
           0x2F -> 0x3F
           0x2B -> 0x3E
        end
    end
  end
end
