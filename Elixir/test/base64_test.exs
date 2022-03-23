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

  def time_test(func, msg) do
    t0 = System.system_time(:millisecond)
    func.()
    t1 = System.system_time(:millisecond)
    IO.puts("<#{msg}> completed in #{(t1 - t0) / 1_000} seconds")
  end

  test "Benchmark 10K Encode Sync" do
    IO.puts "10K Enc Sync -----------------------"
    fn -> Enum.each(1..10_000, fn _ -> @big_string |> Base64.encode() end) end |> time_test("Naive 10K Enc Sync")
    fn -> Enum.each(1..10_000, fn _ -> @big_string |> Base64Opt.encode() end) end |> time_test("Opt 10K Enc Sync")
    fn -> Enum.each(1..10_000, fn _ -> @big_string |> Base.encode64() end) end |> time_test("Builtin 10K Enc Sync")
  end

  test "Benchmark 10K Decode Sync" do
    encoded = @big_string |> Base64.encode()
    IO.puts "10K Dec Sync -----------------------"
    fn -> Enum.each(1..10_000, fn _ -> encoded |> Base64.decode() end) end |> time_test("Naive 10K Dec Sync")
    fn -> Enum.each(1..10_000, fn _ -> encoded |> Base64Opt.decode() end) end |> time_test("Opt 10K Dec Sync")
    fn -> Enum.each(1..10_000, fn _ -> encoded |> Base.decode64() end) end |> time_test("Builtin 10K Dec Sync")
  end

  test "Benchmark 10K Enc/Dec Sync" do
    IO.puts "10K EncDec Sync -----------------------"
    fn -> Enum.each(1..10_000, fn _ -> @big_string |> Base64.encode() |> Base64.decode() end) end |> time_test("Naive 10K EncDec Sync")
    fn -> Enum.each(1..10_000, fn _ -> @big_string |> Base64Opt.encode() |> Base64Opt.decode() end) end |> time_test("Opt 10K EncDec Sync")
    fn -> Enum.each(1..10_000, fn _ -> @big_string |> Base.encode64() |> Base.decode64() end) end |> time_test("Builtin 10K EncDec Sync")
  end

  test "Benchmark 10K Enc/Dec Async" do
    IO.puts "10K EncDec Async -----------------------"
    fn -> Task.async_stream(1..10_000, fn _ -> @big_string |> Base64.encode() |> Base64.decode() end) |> Enum.to_list() end |> time_test("Naive 10K EncDec Async")
    fn -> Task.async_stream(1..10_000, fn _ -> @big_string |> Base64Opt.encode() |> Base64Opt.decode() end) |> Enum.to_list() end |> time_test("Opt 10K EncDec Async")
    fn -> Task.async_stream(1..10_000, fn _ -> @big_string |> Base.encode64() |> Base.decode64() end) |> Enum.to_list() end |> time_test("Builtin 10K EncDec Async")
  end
end
