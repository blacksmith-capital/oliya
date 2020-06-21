defmodule Oliya.Retriever do
  defmodule Params do
    @type t :: %Params{
            from: DateTime.t(),
            granularity: any,
            symbol: any,
            to: DateTime.t(),
            venue: any
          }

    @enforce_keys ~w(from to symbol granularity venue)a
    defstruct ~w(from to symbol granularity venue)a
  end

  defmodule Reseponse do
    @derive Jason.Encoder

    @type t :: %Reseponse{
            columns: any,
            data: any,
            from: DateTime.t(),
            granularity: any,
            symbol: any,
            to: DateTime.t(),
            venue: any
          }

    @enforce_keys ~w(columns data venue symbol from to granularity)a
    defstruct ~w(columns data venue symbol from to granularity)a
  end

  @type query_params :: Params.t()
  @type response :: Reseponse.t()

  @callback fetch(query_params) :: {:ok, response}
  def fetch(params), do: backend().fetch(params)

  def to_params(%{} = params) do
    params
    |> Map.update!("from", &to_datetime/1)
    |> Map.update!("to", &to_datetime/1)
    |> Map.update!("symbol", &String.downcase/1)
    |> Map.update!("venue", &String.downcase/1)
    |> Mapail.map_to_struct!(Params)
  end

  defp backend do
    Application.get_env(:oliya, :fetcher_backend, Oliya.Retriever.Postgres.Retriever)
  end

  defp to_datetime(timestamp),
    do: timestamp |> String.to_integer(10) |> DateTime.from_unix!(:millisecond)
end
