defmodule Base64Test do
  use ExUnit.Case
  doctest Base64

  test "Encodes and Decodes" do
    assert "12345678" |> Base64.encode |> Base64.decode == "12345678"
  end

  test "Encodes" do
    assert "12345678" |> Base64.encode == "MTIzNDU2Nzg="
  end

  test "Decodes" do
    assert "QUJDYWJjMTIzWFlaeHl6" |> Base64.decode == "ABCabc123XYZxyz"
  end
end
