defmodule Base64Test do
  use ExUnit.Case, async: false

  test "Encodes and Decodes" do
    assert "12345678" |> Base64.encode() |> Base64.decode() == "12345678"
    assert "12345678" |> Base64Opt.encode() |> Base64Opt.decode() == "12345678"
  end

  test "Encodes" do
    assert "12345678" |> Base64.encode() == "MTIzNDU2Nzg="
    assert "12345678" |> Base64Opt.encode() == "MTIzNDU2Nzg="
  end

  test "Decodes" do
    assert "QUJDYWJjMTIzWFlaeHl6" |> Base64.decode() == "ABCabc123XYZxyz"
    assert "QUJDYWJjMTIzWFlaeHl6" |> Base64Opt.decode() == "ABCabc123XYZxyz"
  end

  @big_string """
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum mi purus,
  mollis et pulvinar quis, elementum non felis. Ut bibendum dolor ut mauris tempus, euismod
  ultricies odio vulputate. Nunc finibus elit non venenatis maximus. Maecenas in mollis ipsum,
  mattis laoreet purus. Sed lacus purus, tempus vel elementum sed, rutrum nec massa. Mauris
  mattis libero vitae nunc tempor, eget posuere ipsum molestie. Curabitur semper tempus diam.
  Morbi rutrum sollicitudin augue, rhoncus viverra velit volutpat vitae.
  """

  def time_test(func, n, msg) do
    t0 = System.system_time(:millisecond)
    Enum.each(1..n, func)
    t1 = System.system_time(:millisecond)
    IO.puts("<#{msg}> completed in #{(t1 - t0) / 1_000} seconds")
  end

  test "Benchmark 10K Encode" do
    IO.puts("10K Enc Sync -----------------------")
    fn _ -> Base64.encode(@big_string) end |> time_test(10_000, "Naive 10K Enc Sync")
    fn _ -> Base64Opt.encode(@big_string) end |> time_test(10_000, "Opt 10K Enc Sync")
    fn _ -> Base.encode64(@big_string) end |> time_test(10_000, "Builtin 10K Enc Sync")
  end

  test "Benchmark 10K Decode" do
    encoded = @big_string |> Base64.encode()
    IO.puts("10K Dec Sync -----------------------")
    fn _ -> Base64.decode(encoded) end |> time_test(10_000, "Naive 10K Dec Sync")
    fn _ -> Base64Opt.decode(encoded) end |> time_test(10_000, "Opt 10K Dec Sync")
    fn _ -> Base.decode64(encoded) end |> time_test(10_000, "Builtin 10K Dec Sync")
  end

  test "Benchmark 100K Encode + Decode" do
    IO.puts("100K EncDec Sync -----------------------")

    fn _ -> @big_string |> Base64.encode() |> Base64.decode() end
    |> time_test(100_000, "Naive 100K EncDec Sync")

    fn _ -> @big_string |> Base64Opt.encode() |> Base64Opt.decode() end
    |> time_test(100_000, "Opt 100K EncDec Sync")

    fn _ -> @big_string |> Base.encode64() |> Base.decode64() end
    |> time_test(100_000, "Builtin 100K EncDec Sync")
  end
end
