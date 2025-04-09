# WHY ELIXIR?

- **Functional Programming**
- **Pipeline Syntax**
- **Pattern Matching**
- **Meta Programming**

```elixir
"Elixir" |> String.graphemes() |> Enum.frequencies()

defmacro something(path, do: block) do
    #some logic
    unquote(block)
end
something "/hi" do
    IO.puts("I love Elixir")
end
```

- **Phoenix Framework**

## [Elixir official site](https://elixir-lang.org/)

## [Official docs](https://hexdocs.pm/learning)
