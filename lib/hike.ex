defmodule Hike do
  @moduledoc """
  The `Hike` module provides an implementation of the Optional data types.
  It defines

  * a struct `Hike.Option` with a single field `value` which can either be `nil`
  or any other value of type `t`.

  * a struct `Hike.Either` that represents an "either/or" value.
    It can contain either a `left` value or a `right` value, but not both

  * a struct `Hike.MayFail`that represents an "either/or" value.
    It can contain either a `Failure` value or a `Success` value, but not both.

  This implementation provides shorthand functions to work with Optional data, including mapping, filtering, applying and many more functions to the value
  inside the Optional data.
  """

  alias Hike.Option, as: Option
  alias Hike.Either, as: Either
  alias Hike.MayFail, as: MayFail

  @spec option() :: Hike.Option.option()
  def option(), do: Option.none()

  @spec option({:ok, t()}) :: Hike.Option.option(t())
  def option({:ok, value}), do: Hike.Option.some(value)

  @spec option({:error, exception()}) :: Hike.Option.option()
  def option({:error, _}), do: Hike.Option.none()

  @spec option(t) :: Hike.Option.option() | Hike.Option.option(t())
  def option(value) do
    case value do
      nil -> Hike.Option.none()
      val -> Hike.Option.some(val)
    end
  end

  @spec map(Hike.Option.option(), Hike.Option.mapper()) :: Hike.Option.option(t())
  @spec map(Hike.Option.option(), Hike.Option.mapper() | Hike.Option.mapper(t)) ::
          Hike.Option.option()
  def map(%Hike.Option{} = opt, func), do: Hike.Option.map(opt, func)

  @spec apply(Hike.Option.option(t), Hike.Option.func(t)) :: Hike.Option.option(tr)
  @spec apply(Hike.Option.option(), Hike.Option.func() | Hike.Option.func(t)) ::
          Hike.Option.option()
  def apply(%Hike.Option{} = opt, func), do: Hike.Option.apply(opt, func)

  @spec bind(Hike.Option.option(), Hike.Option.binder() | Hike.Option.binder(t)) ::
          Hike.Option.option()
  @spec bind(Hike.Option.option(t), Hike.Option.binder(t)) :: Hike.Option.option(tr)
  def bind(%Hike.Option{} = opt, func), do: Hike.Option.bind(opt, func)

  @spec match(
          Hike.Option.option(t) | Hike.Option.option(),
          Hike.Option.func(t),
          Hike.Option.func()
        ) :: tr()
  def match(%Hike.Option{} = opt, some_func, none_func),
    do: Hike.Option.match(opt, some_func, none_func)

  @spec match(
          Either.either(Either.t_left(), Either.t_right()),
          (Either.t_left() -> tr),
          (Either.t_right() -> tr)
        ) :: tr
  def match(%Hike.Either{} = eth, left_func, right_func),
    do: Hike.Either.match(eth, left_func, right_func)

  @spec match(
          MayFail.mayfail(MayFail.t_failure(), MayFail.t_success()),
          (MayFail.t_failure() -> tr()),
          (MayFail.t_success() -> tr())
        ) :: tr()
  def match(%MayFail{} = mayfail, failure_func, success_func),
    do: MayFail.match(mayfail, failure_func, success_func)

  def filter(%Hike.Option{} = opt, func), do: Hike.Option.filter(opt, func)

  ## EITHER
  @spec either({:ok, t()}) :: Either.either_right(t())
  def either({:ok, value}), do: Hike.Either.right(value)
  @spec either({:error, t()}) :: Either.either_left(t())
  def either({:error, msg}), do: Hike.Either.left(msg)
  @spec either(t()) :: Either.either_right(t())
  def either(value), do: Hike.Either.right(value)

  @spec left(t()) :: Either.either_left(t())
  def left(value), do: Hike.Either.left(value)
  @spec right(t()) :: Either.either_right(t())
  def right(value), do: Hike.Either.right(value)

  @spec apply_left(Either.either_left(Either.t_left()), (Either.t_left() -> tr())) ::
          Either.either_left(tr())
  @spec apply_left(Either.either_right(Either.t_right()), (Either.t_left() -> tr())) ::
          Either.either_right(Either.t_right())
  def apply_left(%Hike.Either{} = eth, func), do: Hike.Either.apply_left(eth, func)

  @spec apply_right(Either.either_right(Either.t_right()), (Either.t_right() -> tr)) ::
          Either.either_right(tr())
  @spec apply_right(Either.either_left(Either.t_left()), (Either.t_right() -> tr())) ::
          Either.either_left(Either.t_left())
  def apply_right(%Hike.Either{} = eth, func), do: Hike.Either.apply_right(eth, func)

  @spec bind_left(Either.either_left(Either.t_left()), Either.binder(Either.t_left())) ::
          Either.either_left(tr) | Either.either_right(tr)
  @spec bind_left(Either.either_right(Either.t_right()), Either.binder(Either.t_left())) ::
          Either.either_right(Either.t_right())
  def bind_left(%Hike.Either{} = eth, func), do: Hike.Either.bind_left(eth, func)

  @spec bind_right(Either.either_right(Either.t_right()), Either.binder(Either.t_right())) ::
          Either.either_right(tr) | Either.either_left(tr)
  @spec bind_right(Either.either_left(Either.t_left()), Either.binder(Either.t_right())) ::
          Either.either_left(Either.t_left())
  def bind_right(%Hike.Either{} = eth, func), do: Hike.Either.bind_right(eth, func)

  @spec map_left(Either.either_left(Either.t_left()), (Either.t_left() -> tr())) ::
          Either.either_left(tr())
  @spec map_left(Either.either_right(Either.t_right()), (Either.t_left() -> tr())) ::
          Either.either_right(Either.t_right())
  def map_left(%Hike.Either{} = eth, func), do: Hike.Either.map_left(eth, func)

  @spec map_right(Either.either_right(Either.t_right()), (Either.t_right() -> tr())) ::
          Either.either_right(tr())
  @spec map_right(Either.either_left(Either.t_left()), (Either.t_right() -> tr())) ::
          Either.either_left(Either.t_left())
  def map_right(%Hike.Either{} = eth, func), do: Hike.Either.map_right(eth, func)

  ## MayFail
  @spec mayfail({:ok, t()}) :: MayFail.mayfail_success(t())
  def mayfail({:ok, value}), do: Hike.MayFail.success(value)
  @spec mayfail({:error, exception()}) :: MayFail.mayfail_failure(exception())
  def mayfail({:error, msg}), do: Hike.MayFail.failure(msg)
  @spec mayfail(t()) :: MayFail.mayfail_success(t())
  def mayfail(value), do: Hike.MayFail.success(value)

  @spec success(t()) :: MayFail.mayfail_success(t())
  def success(value), do: Hike.MayFail.success(value)
  @spec failure(exception()) :: MayFail.mayfail_failure(exception())
  def failure(msg), do: Hike.MayFail.failure(msg)

  @spec apply_success(
          MayFail.mayfail_success(MayFail.t_success()),
          MayFail.func(MayFail.t_success())
        ) :: MayFail.mayfail_success(tr())
  @spec apply_success(
          MayFail.mayfail_failure(MayFail.t_failure()),
          MayFail.func(MayFail.t_success())
        ) ::
          MayFail.mayfail_failure(MayFail.t_failure())
  def apply_success(%Hike.MayFail{} = mayfail, func),
    do: Hike.MayFail.apply_success(mayfail, func)

  @spec apply_failure(
          MayFail.mayfail_failure(MayFail.t_failure()),
          MayFail.func(MayFail.t_failure())
        ) :: MayFail.mayfail_failure(tr())
  @spec apply_failure(
          MayFail.mayfail_success(MayFail.t_success()),
          MayFail.func(MayFail.t_failure())
        ) ::
          MayFail.mayfail_success(MayFail.t_success())
  def apply_failure(%Hike.MayFail{} = mayfail, func),
    do: Hike.MayFail.apply_failure(mayfail, func)

  @spec map_success(MayFail.mayfail_success(MayFail.t_success()), MayFail.mapper()) ::
          MayFail.mayfail_success(tr())
  @spec map_success(
          MayFail.mayfail_failure(MayFail.t_failure()),
          MayFail.mapper(MayFail.t_success())
        ) ::
          MayFail.mayfail_failure(MayFail.t_failure())
  def map_success(%Hike.MayFail{} = mayfail, func), do: Hike.MayFail.map_success(mayfail, func)

  @spec map_failure(
          MayFail.mayfail_failure(MayFail.t_failure()),
          MayFail.mapper(MayFail.t_failure())
        ) :: MayFail.mayfail_failure(tr())
  @spec map_failure(
          MayFail.mayfail_failure(MayFail.t_success()),
          MayFail.mapper(MayFail.t_failure())
        ) ::
          MayFail.mayfail_failure(MayFail.t_success())
  def map_failure(%Hike.MayFail{} = mayfail, func), do: Hike.MayFail.map_failure(mayfail, func)

  @spec bind_success(
          MayFail.mayfail_success(MayFail.t_success()),
          MayFail.binder(MayFail.t_success())
        ) :: MayFail.mayfail_success(tr())
  @spec bind_success(
          MayFail.mayfail_failure(MayFail.t_failure()),
          MayFail.binder(MayFail.t_success())
        ) ::
          MayFail.mayfail_failure(MayFail.t_failure())
  def bind_success(%Hike.MayFail{} = mayfail, func), do: Hike.MayFail.bind_success(mayfail, func)

  @spec bind_failure(
          MayFail.mayfail_failure(MayFail.t_failure()),
          MayFail.binder(MayFail.t_failure())
        ) :: MayFail.mayfail_failure(tr())
  @spec bind_failure(
          MayFail.mayfail_failure(MayFail.t_success()),
          MayFail.binder(MayFail.t_failure())
        ) ::
          MayFail.mayfail_failure(MayFail.t_success())
  def bind_failure(%Hike.MayFail{} = mayfail, func), do: Hike.MayFail.bind_failure(mayfail, func)

  @typedoc """
  generic input type `<T>`.
  """
  @type t :: any()

  @typedoc """
  generic input type `<TArg1>`.
  """
  @type tArg1 :: any()

  @typedoc """
  generic input type `<TArg2>`.
  """
  @type tArg2 :: any()
  @typedoc """
  generic input type `<TArg3>`.
  """
  @type tArg3 :: any()

  @typedoc """
  generic input type `<TArg4>`.
  """
  @type tArg4 :: any()

  @typedoc """
  generic return type `<TR>`.
  """
  @type tr :: any()

  @type exception :: :error

  @doc """
  wraps a function call if function runs successfully will return `MayFail` in `Success` state
    otherwise return `MayFail` in `Failure` state.
  """

  @spec try((() -> tr() | exception())) :: Hike.MayFail.mayfail()
  def try(func) when is_function(func, 0) do
    try do
      func.() |> Hike.MayFail.success()
    rescue
      x -> Hike.MayFail.failure(x.message)
    end
  end

  @doc """
  wraps a function with arity 1 call if function runs successfully will return `MayFail` in `Success` state
    otherwise return `MayFail` in `Failure` state.

  ## Example
      iex>  add1 = fn (x) -> x + 1 end
      iex>  Hike.try(add1, 5) |> Hike.MayFail.map_success(fn  x -> x end )
      %Hike.MayFail{failure: nil, success: 6, is_success?: true}

  """
  @spec try((tArg1() -> tr() | exception()), tArg1) :: Hike.MayFail.mayfail()
  def try(func, arg1) when is_function(func, 1) do
    try do
      func.(arg1) |> Hike.MayFail.success()
    rescue
      x -> Hike.MayFail.failure(x.message)
    end
  end

  @doc """
  wraps a function with arity 2 call if function runs successfully will return `MayFail` in `Success` state
    otherwise return `MayFail` in `Failure` state.

  ## Example
      iex>  divide = fn (x, y) -> x / y end
      iex>  Hike.try(divide, 5, 0) |>
      ...>  Hike.MayFail.map_success(fn  x -> {:ok, x + 1} end ) |>
      ...>  Hike.MayFail.map_failure(fn x -> String.upcase(x) end)

        %Hike.MayFail{
          failure: "BAD ARGUMENT IN ARITHMETIC EXPRESSION",
          success: nil,
          is_success?: false
        }

  """
  @spec try((tArg1(), tArg2() -> tr() | exception()), tArg1(), tArg2()) :: Hike.MayFail.mayfail()
  def try(func, arg1, arg2) when is_function(func, 2) do
    try do
      func.(arg1, arg2) |> Hike.MayFail.success()
    rescue
      x -> Hike.MayFail.failure(x.message)
    end
  end

  @doc """
  wraps a function with arity 3 call if function runs successfully will return `MayFail` in `Success` state
    otherwise return `MayFail` in `Failure` state.
  """
  @spec try((tArg1(), tArg2(), tArg3() -> tr() | exception()), tArg1(), tArg2(), tArg3()) ::
          Hike.MayFail.mayfail()
  def try(func, arg1, arg2, arg3) when is_function(func, 3) do
    try do
      func.(arg1, arg2, arg3) |> Hike.MayFail.success()
    rescue
      x -> Hike.MayFail.failure(x.message)
    end
  end

  @doc """
  wraps a function with arity 4 call if function runs successfully will return `MayFail` in `Success` state
    otherwise return `MayFail` in `Failure` state.
  """
  @spec try(
          (tArg1(), tArg2(), tArg3(), tArg4() -> tr() | exception()),
          tArg1(),
          tArg2(),
          tArg3(),
          tArg4()
        ) :: Hike.MayFail.mayfail()
  def try(func, arg1, arg2, arg3, arg4) when is_function(func, 4) do
    try do
      func.(arg1, arg2, arg3, arg4) |> Hike.MayFail.success()
    rescue
      x -> Hike.MayFail.failure(x.message)
    end
  end
end
