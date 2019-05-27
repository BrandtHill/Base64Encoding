defmodule Timer do
  @big_string """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum mi purus,
mollis et pulvinar quis, elementum non felis. Ut bibendum dolor ut mauris tempus, euismod
ultricies odio vulputate. Nunc finibus elit non venenatis maximus. Maecenas in mollis ipsum,
mattis laoreet purus. Sed lacus purus, tempus vel elementum sed, rutrum nec massa. Mauris
mattis libero vitae nunc tempor, eget posuere ipsum molestie. Curabitur semper tempus diam.
Morbi rutrum sollicitudin augue, rhoncus viverra velit volutpat vitae.\r\n
""";

  def start(_type, _args) do
    IO.puts(@big_string |> Base64.encode |> Base64.decode)
    t0 = System.system_time(:millisecond)
    Enum.each(1..10000, fn _x -> @big_string |> Base64.encode |> Base64.decode end)
    t1 = System.system_time(:millisecond)
    IO.puts("Completed in #{(t1 - t0)/1_000} seconds")
  end

end