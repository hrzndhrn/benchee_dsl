defmodule FormattterBench do
  use BencheeDsl.Benchmark

  config time: 1

  formatter Benchee.Formatters.Markdown,
    file: Path.expand("formatter.md", __DIR__),
    description: """
    Bla bla bla ...
    """

  job do_it do
    1 + 1
  end
end
