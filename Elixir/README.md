# Base64

Most of this is auto generated, so if you want the main README, go to the root of this repo.
For other languages I had index/reverse tables, but for this implementation, I took advantage 
of the cool Elixir 'cond' block and pattern matching neatness. I also measured the benchmark
results using Async test results (about 66% faster on my 4-core PC), because Elixir is known
for its exceptional concurrency model and the code was virtually identical to the Sync test.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `base64` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:base64, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/base64](https://hexdocs.pm/base64).

