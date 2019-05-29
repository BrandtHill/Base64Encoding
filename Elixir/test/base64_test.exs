defmodule Base64Test do
  use ExUnit.Case, async: false
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

  @big_string """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum mi purus,
mollis et pulvinar quis, elementum non felis. Ut bibendum dolor ut mauris tempus, euismod
ultricies odio vulputate. Nunc finibus elit non venenatis maximus. Maecenas in mollis ipsum,
mattis laoreet purus. Sed lacus purus, tempus vel elementum sed, rutrum nec massa. Mauris
mattis libero vitae nunc tempor, eget posuere ipsum molestie. Curabitur semper tempus diam.
Morbi rutrum sollicitudin augue, rhoncus viverra velit volutpat vitae.
"""

  test "Benchmark 10K Encode Sync" do
    t0 = System.system_time(:millisecond)
    Enum.each(1..10_000, fn _x -> @big_string |> Base64.encode end)
    t1 = System.system_time(:millisecond)
    IO.puts("10K Enc Sync completed in #{(t1 - t0)/1_000} seconds")
  end

  test "Benchmark 10K Decode Sync" do
    encoded = @big_string |> Base64.encode
    t0 = System.system_time(:millisecond)
    Enum.each(1..10_000, fn _x -> encoded |> Base64.decode end)
    t1 = System.system_time(:millisecond)
    IO.puts("10K Dec Sync completed in #{(t1 - t0)/1_000} seconds")
  end

  test "Benchmark 10K Enc/Dec Sync" do
    t0 = System.system_time(:millisecond)
    Enum.each(1..10_000, fn _x -> @big_string |> Base64.encode |> Base64.decode end)
    t1 = System.system_time(:millisecond)
    IO.puts("10K Enc & Dec Sync completed in #{(t1 - t0)/1_000} seconds")
  end

  test "Benchmark 10K Encode Async" do
    t0 = System.system_time(:millisecond)
    Task.async_stream(1..10_000, fn _x -> @big_string |> Base64.encode end) |> Enum.to_list
    t1 = System.system_time(:millisecond)
    IO.puts("10K Enc Async completed in #{(t1 - t0)/1_000} seconds")
  end

  test "Benchmark 10K Decode Async" do
    encoded = @big_string |> Base64.encode
    t0 = System.system_time(:millisecond)
    Task.async_stream(1..10_000, fn _x -> encoded |> Base64.decode end) |> Enum.to_list
    t1 = System.system_time(:millisecond)
    IO.puts("10K Dec Async completed in #{(t1 - t0)/1_000} seconds")
  end

  test "Benchmark 10K Enc/Dec Async" do
    t0 = System.system_time(:millisecond)
    Task.async_stream(1..10_000, fn _x -> @big_string |> Base64.encode |> Base64.decode end) |> Enum.to_list
    t1 = System.system_time(:millisecond)
    IO.puts("10K Enc & Dec Async completed in #{(t1 - t0)/1_000} seconds")
  end

end
