defmodule Hike.Either do
  alias __MODULE__, as: Either

  @typedoc """
  generic input type `<T>`.
  """

  @type t :: any()

  @typedoc """
  generic return type `<TR>`.
  """
  @type tr :: any()

  @typedoc """
  `func()` represent a function which take no parameter and return value of type `<TR>`.
  """
  @type func :: (() -> tr)

  @typedoc """
  `func(t)` represent a function which take a parameter of type `<T>`
  and return a value of type `<TR>`.
  """
  @type func(t) :: (t -> tr)

  @typedoc """
  `mapper()` represent a mapping function which take no parameter and return
  a value of type `<TR>`.
  """
  @type mapper :: (() -> tr)

  @typedoc """
  `mapper(t)` represent a mapping function which take a parameter of type `<T>`
  and return a value of type `<TR>`.
  """
  @type mapper(t) :: (t -> tr)

  @typedoc """
  `binder()` represent a binding(mapping) function which take no parameter and
  return an Either of type `<TR>`.

  ## Example
      iex> right_bind_func = fn () -> Either.right(:ok) end
      iex> left_bind_func = fn () -> Either.left(:ok) end
  """
  @type binder :: (() -> either_left(tr) | either_right(tr))

  @typedoc """
  `binder(t)` represent a binding(mapping) function which take a parameter of type `<T>`
    and return an `Either` of type `<TR>`.

  ## Example
      iex> right_bind_func = fn (x) -> Either.right(x) end
      iex> left_bind_func = fn (y) -> Either.left(y) end
  """
  @type binder(t) :: (t -> either_left(tr) | either_right(tr))

  @typedoc """
    generic input type `<T_Left>` represent a type of value on `Left`state.
  """
  @type t_left :: any()

  @typedoc """
  generic input type `<T_Right>`represent a type of value on `Right`state.
  """
  @type t_right :: any()

  @typedoc """
  represent a type of `Either` that could be in either `Left` or `Right` state
  with a value of given type.
  """
  @type either(t_left, t_right) :: %__MODULE__{
          l_value: t_left,
          r_value: t_right,
          is_left?: boolean()
        }
  @typedoc """
  represent a type of `Either` that could be in either `Left` or `Right` state
  """
  @opaque either() :: %__MODULE__{
            l_value: t_left(),
            r_value: t_right(),
            is_left?: boolean()
          }
  @typedoc """
  Elevated data type of `Either` struct that represents `Right` state.
  """
  @type either_right :: %__MODULE__{
          l_value: nil,
          r_value: t_right(),
          is_left?: false
        }
  @typedoc """
  Elevated data type of `Either` struct that represents `Right` state and have a value of type `<T>`.
  """
  @type either_right(t) :: %__MODULE__{
          l_value: nil,
          r_value: t,
          is_left?: false
        }

  @typedoc """
  represent a type of `Either` in `Left` state.
  """
  @type either_left :: %__MODULE__{
          l_value: t_left(),
          r_value: nil,
          is_left?: true
        }
  @typedoc """
  represent a type of `Either` in `Left` state.
  """
  @type either_left(t) :: %__MODULE__{
          l_value: t,
          r_value: nil,
          is_left?: true
        }
  @doc """
  `%Hike.Either{l_value: t_left(), r_value: t_right(), is_left?:boolean()}` is a struct that represents an "either/or" value.
  It can contain either a `left` value or a `right` value, but not both.

  * `l_value`: the left value (if `is_left?` is true)
  * `r_value`: the right value (if `is_left?` is false)
  * `is_left?`: a boolean flag indicating whether the value is a left value (`true`) or a right value (`false`)
  """
  defstruct [:l_value, :r_value, :is_left?]

  defmacro is_not_nil(value) do
    quote do
      unquote(value) !== nil
    end
  end

  @doc """
  Creates a new Left Either object with a given value for the left side.

  ## Examples

      iex> left("foo bar")
      %Hike.Either{l_value: "foo bar", r_value: nil, is_left?: true}
  """
  @spec left(t_left) :: Either.either_left(t_left)
  def left(value) when is_not_nil(value),
    do: %__MODULE__{l_value: value, r_value: nil, is_left?: true}

  def left(nil), do: raise(ArgumentError, message: "Left value cannot be nil")

  @doc """
  Creates a new `Either` in `Right` state with a given value.

  ## Examples

      iex> right("foo bar")
      %Hike.Either{l_value: nil, r_value: "foo bar", is_left?: false}

  """
  @spec right(t_right()) :: Either.either_right(t_right)
  def right(value) when is_not_nil(value),
    do: %__MODULE__{l_value: nil, r_value: value, is_left?: false}

  def right(nil), do: raise(ArgumentError, message: "Right value cannot be nil")

  @doc """
  Check whether an`either` is in `Left` state or not .

  ## Examples

      iex> right("foo bar") |> Either.is_left?()
       false
      iex> left("foo bar") |> Either.is_left?()
       true
  """
  @spec is_left?(Either.either()) :: boolean()
  def is_left?(%__MODULE__{is_left?: true} = _either), do: true
  def is_left?(_), do: false

  @doc """
  Check whether an`either` is in `Right` state or not .

  ## Examples

      iex> right("foo bar") |> Either.is_right?()
       true
      iex> left("foo bar") |> Either.is_right?()
       false
  """
  @spec is_right?(Either.either()) :: boolean()
  def is_right?(%__MODULE__{is_left?: false} = _either), do: true
  def is_right?(_), do: false

  @doc """
    `apply_left` applies a given function to a given `Either` if `Either` is in left state and
    return a new `Either` with new transformed value in `Left` state
  else return new `Either` in `Right` state with existing right value.

  ## Examples

      iex> (Either.left 5) |> Either.apply_left(fn num -> num + num end)
      %Hike.Either{l_value: 10, r_value: nil, is_left?: true}

      iex> (Either.right 5) |> Either.apply_left(fn num -> num + num end)
      %Hike.Either{l_value: nil, r_value: 5, is_left?: false}
  """
  @spec apply_left(Either.either_left(t_left()), (t_left() -> tr())) :: Either.either_left(tr())
  def apply_left(%__MODULE__{l_value: l_value, is_left?: true} = _either, func)
      when is_function(func, 1),
      do: func.(l_value) |> left

  @spec apply_left(Either.either_right(t_right), (t_left() -> tr())) ::
          Either.either_right(t_right())
  def apply_left(%__MODULE__{r_value: r_value, is_left?: false} = _either, _func),
    do: r_value |> right

  @doc """
  `apply_right` applies a given function to a given `Either` if `Either` is in right state and
    return a new `Either` with new transformed value in `Right` state
  else return new `Either` in `Left` state with existing left value.
  ## Examples

      iex> (Either.right "hello") |> Either.apply_right(fn str -> String.upcase(str) end)
      %Hike.Either{l_value: nil, r_value: "HELLO", is_left?: false}

      iex> (Either.left "hello") |> Either.apply_right(fn str -> String.upcase(str) end)
      %Hike.Either{l_value: "hello", r_value: nil, is_left?: true}
  """
  @spec apply_right(Either.either_left(t_left), (t_right() -> tr())) ::
          Either.either_left(t_left())
  def apply_right(%__MODULE__{l_value: l_value, is_left?: true} = _either, func)
      when is_function(func, 1),
      do: l_value |> left

  @spec apply_right(Either.either_right(t_right()), (t_right() -> tr)) ::
          Either.either_right(tr())
  def apply_right(%__MODULE__{r_value: r_value, is_left?: false} = _either, func)
      when is_function(func, 1),
      do: func.(r_value) |> right

  @doc """
  Maps the value of the `Either` from left state using the given function.

  If the `Either` is in the right state, the function returns the `Either`
  unchanged. If the `Either` is in the left state, the function applies the
  given function to the value of the left state, and returns a new `Either`
  with the transformed value.

  ## Examples
      iex> (Either.left 5) |> Either.map_left(fn num -> num + num end)
      %Hike.Either{l_value: 10, r_value: nil, is_left?: true}

      iex> (Either.right 5) |> Either.map_left(fn num -> num + num end)
      %Hike.Either{l_value: nil, r_value: 5, is_left?: false}

      iex> either = %Either{l_value: "hello", is_left?: true}
      iex> new_either = Either.map_left(either, &String.upcase/1)
      %Hike.Either{l_value: "HELLO", is_left?: true}

      iex> either = %Either{r_value: 10, is_left?: false}
      iex> new_either = Either.map_left(either, &String.downcase/1)
      %Hike.Either{r_value: 10, is_left?: false}
  """

  @spec map_left(Either.either_left(t_left()), (t_left() -> tr())) :: Either.either_left(tr())
  def map_left(%__MODULE__{l_value: l, r_value: _r, is_left?: true} = _e, func)
      when is_function(func, 1) do
    left(func.(l))
  end

  @spec map_left(Either.either_right(t_right()), (t_left() -> tr())) ::
          Either.either_right(t_right())
  def map_left(%__MODULE__{l_value: _l, r_value: r, is_left?: false} = _e, _f) do
    right(r)
  end

  @doc """
  Maps the value of the`Either` from right state using the given function.

  If the `Either` is in the left state, the function returns the `Either`
  unchanged. If the `Either` is in the right state, the function applies the
  given function to the value of the right state, and returns a new `Either`
  with the transformed value.

  ## Examples

      iex> (Either.right "hello") |> Either.map_right(fn str -> String.upcase(str) end)
      %Hike.Either{l_value: nil, r_value: "HELLO", is_left?: false}

      iex> (Either.left "hello") |> Either.map_right(fn str -> String.upcase(str) end)
      %Hike.Either{l_value: "hello", r_value: nil, is_left?: true}
  """

  @spec map_right(Either.either_right(t_right()), (t_right -> tr())) :: Either.either_right(tr())
  def map_right(%__MODULE__{l_value: _l, r_value: r, is_left?: false} = _either, func)
      when is_function(func, 1),
      do: func.(r) |> right

  @spec map_right(Either.either_left(t_left()), (t_right -> tr())) :: Either.either_left(t_left())
  def map_right(%__MODULE__{l_value: l, r_value: _r, is_left?: true} = _either, _func),
    do: left(l)

  @doc """
  Binds a function that returns an `Either` value for an `Either` in the left state.
  If the input Either is in the right state,
  the function is not executed and the input Either is returned as is.

  ## Examples

      iex> (Either.left "hello") |> Either.bind_left(fn str -> Either.left(String.upcase(str)) end)
      %Hike.Either{l_value: "HELLO", r_value: nil, is_left?: true}

      iex> (Either.left "hello") |> Either.bind_left(fn str -> Either.right(String.upcase(str)) end)
      %Hike.Either{l_value: nil, r_value: "HELLO", is_left?: false}

      iex> (Either.right "hello") |> Either.bind_left(fn str -> Either.left(String.upcase(str)) end)
      %Hike.Either{l_value: nil, r_value: "hello", is_left?: false}

  """
  @spec bind_left(Either.either_left(t_left), binder(t_left)) ::
          Either.either_left(tr) | Either.either_right(tr)
  def bind_left(%__MODULE__{l_value: l_val, is_left?: true} = _either, func)
      when is_function(func, 1),
      do: func.(l_val)

  @spec bind_left(Either.either_right(t_right()), binder(t_left)) ::
          Either.either_right(t_right())
  def bind_left(%__MODULE__{l_value: _l_val, r_value: r_val, is_left?: false} = _either, _func),
    do: right(r_val)

  @doc """
  Binds a function that returns an Either value to an Either in the right state.
  If the input Either is in the left state,
  the function is not executed and the input Either is returned as is.

  ## Examples

      iex> (Either.right "hello") |> Either.bind_right(fn str -> Either.right(String.upcase(str)) end)
      %Hike.Either{l_value: nil, r_value: "HELLO", is_left?: false}

      iex> (Either.right "hello") |> Either.bind_right(fn str -> Either.left(String.upcase(str)) end)
      %Hike.Either{l_value: "HELLO", r_value: nil, is_left?: true}

      iex> (Either.left "hello") |> Either.bind_right(fn str -> Either.right(String.upcase(str)) end)
      %Hike.Either{l_value: "hello", r_value: nil, is_left?: true}

  """
  @spec bind_right(Either.either_right(t_right), binder(t_right)) ::
          Either.either_right(tr) | Either.either_left(tr)
  def bind_right(%__MODULE__{r_value: r_val, is_left?: false} = _either, func)
      when is_function(func, 1),
      do: func.(r_val)

  @spec bind_right(Either.either_left(t_left()), binder(t_right())) ::
          Either.either_left(t_left())
  def bind_right(%__MODULE__{l_value: l_val, r_value: _r_val, is_left?: true}, _func),
    do: left(l_val)

  @doc """
  Matches an `Either` value and applies the corresponding function.

  ## Examples

       iex> (Either.left "hello") |> Either.match(fn str -> String.upcase(str) end, fn ()-> "NOT FOUND" end)
       "HELLO"
       iex> (Either.right 4) |> Either.match(fn num-> num * num end, fn num-> num + num end)
       8

  """
  @spec match(Either.either(t_left, t_right), (t_left -> tr), (t_right -> tr)) :: tr
  def match(%__MODULE__{l_value: x, is_left?: true} = _either, left_fn, _)
      when is_function(left_fn, 1),
      do: left_fn.(x)

  def match(%__MODULE__{r_value: x, is_left?: false} = _either, _, right_fn)
      when is_function(right_fn, 1),
      do: right_fn.(x)

  @doc """
  Create new Either from result. if result is `{:ok, val}` `Either` will be in
  right state. else if result is `{:error, val}` `Either` will be in left state.
  with respective value `val` in respective side.
  """
  @spec from_result({:ok, t()}) :: either_right(t())
  @spec from_result({:error, t()}) :: either_left(t())
  def from_result({:error, val}), do: left(val)
  def from_result({:ok, val}), do: right(val)
end
