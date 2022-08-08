defmodule BencheeDsl.SmartCell do
  @moduledoc false

  use Kino.JS
  use Kino.JS.Live
  use Kino.SmartCell, name: "Benchee"

  @editor attribute: "source",
          language: "elixir",
          default_source: """
          defmodule Benchmark do
            use BencheeDsl.Benchmark

            # Add your config, inputs and jobs ...
          end\
          """

  @impl true
  def init(_attrs, ctx), do: {:ok, ctx, editor: @editor}

  @impl true
  def handle_connect(ctx), do: {:ok, %{}, ctx}

  @impl true
  def to_attrs(_ctx), do: %{}

  @impl true
  def to_source(attrs) do
    quote do
      {:module, name, _binary, _bindings} = unquote(source(attrs))

      name.run(
        # return: :result,
        # formatters: [],
        print: [configuration: false, benchmarking: true]
      )
    end
    |> Kino.SmartCell.quoted_to_string()
  end

  defp source(%{"source" => source}) do
    case Code.string_to_quoted(source) do
      {:ok, quoted} -> quoted
      {:error, _reason} -> []
    end
  end

  asset "main.js" do
    """
    export function init(ctx, payload) {
      ctx.importCSS("main.css");

      root.innerHTML = `
        <div class="app">
          <label class="label">Benchee</label>
        </div>
      `;
    }
    """
  end

  asset "main.css" do
    """
    .app {
      display: flex;
      align-items: center;
      gap: 16px;
      background-color: #ecf0ff;
      padding: 8px 16px;
      border: solid 1px #cad5e0;
      border-radius: 0.5rem 0.5rem 0 0;
    }

    .label {
      font-size: 0.875rem;
      font-weight: 500;
      color: #445668;
      text-transform: uppercase;
    }
    """
  end
end
