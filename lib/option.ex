defmodule Hike.Option do
  alias __MODULE__, as: Option

  @moduledoc """
  The `Hike.Option` module provides an implementation of the Optional data type.
  It defines a struct `Option` with a single field `value` which can either be `@none nil`
  or any other value of type `t`. This implementation provides functions to work with
  Optional data, including mapping, filtering, applying and many more functions to the value
  inside the Optional data.

  ## Example Usage

      iex> option = %Hike.Option{value: 42}
      %Hike.Option{value: 42}

      iex> Hike.Option.map(option, &(&1 * 2))
      %Hike.Option{value: 84}

      iex> Hike.Option.filter(option, &(rem(&1, 2) == 0))
      %Hike.Option{value: 42}

      iex> Hike.Option.apply(option, &(&1 + 10))
      %Hike.Option{value: 52}

```elixir
  # Define a User struct
  defmodule User do
  @derive {Jason.Encoder, only: [:id,:age, :name]}
  defstruct [:id, :age, :name]
  end

  defmodule TestHike do
  # Import the Hike.Option module
  import Hike.Option

  # Simulating a database fetch function
  @spec fetch_user(number) :: Hike.Option.t()
  # Simulating a database fetch function
  def fetch_user(id) do
    # Simulating a database query to fetch a user by ID
    # Returns an Option<User> with some(user) if the user is found
    # Returns an Option<User> with none() if the user is not found
    case id do
      1 -> some(%User{id: 1, age: 30, name: "Vineet Sharma"})
      2 -> some(%User{id: 2, age: 20, name: "Jane Smith"})
      _ -> none()
    end
  end

  # Function to update the user's name to uppercase
  # This function takes a user, a real data type, and returns an elevated data type Option
  def update_name_to_uppercase(user) do
    uppercase_name = String.upcase(user.name)
    some(%User{user | name: uppercase_name})
  end


  #   for above function another version could be this is intentionally done to show bind functionality
  #   def update_name_to_uppercase(user) do
  #    uppercase_name = String.upcase(user.name)
  #    %User{user | name: uppercase_name}
  #  end
  # for this case map function will be used like its been used for `increase_age_by1`


  # Function to increase the user's age by one
  # This function takes a user, a real data type, and returns a real data type user
  def increase_age_by1(user) do
    %User{user | age: user.age + 1}
  end

  # Function to print a user struct as a JSON-represented string
  def print_user_as_json(user) do
    Jason.encode!(user) |> IO.puts
  end

  # Example: Fetching a user from the database, updating the name, and matching the result
  def test_user() do
    user_id = 1

    # 1. Expressiveness: Using Hike's Option type to handle optional values
    fetch_user(user_id)
    |> bind(&update_name_to_uppercase/1)
    |> map(&increase_age_by1/1)
    |> match(&print_user_as_json/1, fn -> IO.puts("User not found") end)

    user_id = 3

    # 2. Safer and more predictable code: Handling all possible cases explicitly
    fetch_user(user_id)
    |> bind(&update_name_to_uppercase/1)
    |> map(&increase_age_by1/1)
    |> match(&print_user_as_json/1, fn -> IO.puts("User not found") end)
  end
  end
  ```
  ### Output

  ```shell
  iex> TestHike.test_user
  # User ID: 1
  {"id":1,"age":31,"name":"JOHN DOE"}
  # User ID: 3
  User not found
  ```

  For more information on how to use this module, please see the documentation for
  the individual functions.
  """

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
  `func(t)` represent a function which take a parameter of type `<T>` and return a value of type `<TR>`.
  """
  @type func(t) :: (t -> tr)

  @typedoc """
  `mapper()` represent a mapping function which take no parameter and return a value of type `<TR>`.
  """
  @type mapper :: (() -> tr)

  @typedoc """
  `mapper(t)` represent a mapping function which take a parameter of type `<T>` and return a value of type `<TR>`.
  """
  @type mapper(t) :: (t -> tr)

  @typedoc """
  `binder()` represent a binding(mapping) function which take no parameter and return an option of type `<TR>`.
  """
  @type binder :: (() -> option(tr))

  @typedoc """
  `binder(t)` represent a binding(mapping) function which take a parameter of type `<T>` and return an option of type `<TR>`.
  """
  @type binder(t) :: (t -> option(tr))

  @none nil

  @typedoc """
  Elevated data type of Option struct that represents `None` state.
  """
  @type option() :: %__MODULE__{value: nil}

  @typedoc """
  Elevated data type of Option struct that represents `Some` state and have a value of type `<T>`.
  """
  @type option(t) :: %__MODULE__{value: t}

  defstruct value: @none

  ## Apply function region start
  @doc """
  Applies a given function to the value of an `Option` struct and returns the result as a new `Option`.
    `OR`
  Applies a given function stored in an option to the value of another option, and returns the result as a new option.


  ## Examples

      iex> option = %Option{value: 42}
      iex> add_one = fn x -> x + 1 end
      iex> Option.apply(option, add_one)
      %Option{value: 43}

      iex> none_option = %Option{value: nil}
      iex> Option.apply(none_option, add_one)
      %Option{value: nil}

      iex> option = %Option{value: "hello"}
      iex> upcase_string = fn str -> String.upcase(str) end
      iex> Option.apply(option, upcase_string)
      %Option{value: "HELLO"}


  """

  @spec apply(option(t), func(t)) :: option(tr)
  def apply(%__MODULE__{value: value} = _option, func)
      when value != @none and is_function(func, 1),
      do: func.(value) |> some

  @spec apply(option(), func() | func(t)) :: option()
  def apply(%__MODULE__{value: @none} = opt, _func), do: opt

  def apply(_, _), do: none()

  ## Apply function region end

  ## bind function region start

  @doc """
  Transforms an `Option<T>` struct with a non-nil value using a binder function that returns another `Option<TR>` struct.

  If the input `Option` has a `nil` value, returns a new `Option` struct with a `nil` value.
  if you have a function that return `Option<TR>` and you want to apply mapping then use bind function to avoid double elevation.

  ## Examples

      iex> option = %Option{value: 42}
      iex> add_one = fn x -> Option.some(x + 1) end
      iex> Option.bind(option, add_one)
      %Option{value: 43}

      iex> Option.bind(Option.some("hello"), fn x -> Option.some(String.upcase(x)) end)
      %Option{value: "HELLO"}

      iex> Option.bind(Option.none() )
      %Option{value: nil}


  """

  @spec bind(option(t), binder(t)) :: option(tr)
  def bind(%__MODULE__{value: value}, func)
      when value != @none and is_function(func, 1) do
    func.(value)
  end

  @spec bind(option(), binder() | binder(t)) :: option()
  def bind(%__MODULE__{value: @none} = opt, _func), do: opt

  ## bind function region end

  ## filter function region start
  @doc """
  Applies the given function to the value of the provided option, returning a new option
  containing the original value if the function returns a truthy value, otherwise returning
  an empty option. If the provided option has no value, this function simply returns the
  empty option.

  ## Examples

      iex> Option.filter(%Option{value: 42}, fn x -> rem(x, 2) == 0 end)
      %Option{value: 42}

      iex> Option.filter(%Option{value: 42}, fn x -> rem(x, 2) == 1 end)
      %Option{value: nil}

      iex> Option.filter(%Option{value: nil}, fn x -> rem(x, 2) == 0 end)
      %Option{value: nil}

      iex> list_opt = Option.some([1,2,3])
      iex> list_filter = fn (lst) -> Enum.count(lst) > 5  end
      iex> Option.filter(list_opt, list_filter)
      %Hike.Option{value: nil}

  """
  @spec filter(option(), func()) :: option()
  def filter(%__MODULE__{value: @none} = opt, _func), do: opt

  @spec filter(option(t), func(t)) :: option(tr)
  def filter(%Option{value: value}, func) when value != @none and is_function(func, 1) do
    if func.(value) do
      %Option{value: value}
    else
      %Option{value: @none}
    end
  end

  def filter(_option, _func), do: none()

  ## filter function region end

  ## is_none function region start
  @doc """
  Returns `true` if the `Option` is in `None` state, otherwise `false`.

  ## Examples

      iex> Option.is_none?(Option.none())
      true

      iex> Option.is_none?(Option.some("hello"))
      false

  """
  @spec is_none?(option() | option(t)) :: boolean()
  def is_none?(%__MODULE__{value: value}), do: value == @none

  ## is_none function region end

  ## is_some function region start

  @doc """
  Returns `true` if the `Option` is in `Some` state, otherwise `false`.

  ## Examples

      iex> Option.is_some?(Option.some("hello"))
      true

      iex> Option.is_some?(Option.none())
      false

  """
  @spec is_some?(option() | option(t)) :: boolean()
  def is_some?(%__MODULE__{value: value}), do: value != @none

  ## is_some function region end

  ## map function region start
  @doc """
  Applies the given mapping function to the value inside the `Option` struct and returns a new `Option`
  struct containing the transformed value. If the input `Option` struct is `@none`, the function
  returns a new `Option` struct in none state.
    ## Examples

        iex> Option.map(Option.some("hello"), fn x -> String.upcase(x) end)
        %Option{value: "HELLO"}

        iex> Option.map(Option.none(), fn x -> String.upcase(x) end)
        %Option{value: nil}

  """
  @spec map(option(t), mapper(t)) :: option(tr)
  def map(%__MODULE__{value: value} = _option, func)
      when value != @none and is_function(func, 1),
      do: func.(value) |> some

  @spec map(option(), mapper() | mapper(t)) :: option()
  def map(%__MODULE__{value: @none} = opt, _func), do: opt

  ## map function region end

  ## match function region start

  @doc """
  Matches on an `option` and returns the result of the matching function.
  Calls `some_fun` with the value of the Option if the Option is in `:some` state,
  or calls `none_fun` if the Option is in `:none` state.

  ## Examples

      iex> import Hike.Option

      # Match on `some` value with a matching function
      iex> match(some(10), &(&1 * 2))
      # => 20

      # Match on `none` value with a none-matching function
      iex> match(none(), fn -> "no value" end)
      # => "no value"

      # Match on `some` value with a matching function and on `none` value with a none-matching function
      iex> match(some("hello"), &(&1 <> " world"), fn -> "no value" end)
      # => "hello world"

      # Match on `none` value with a none-matching function even if a matching function is provided
      iex> match(none(), &(&1 * 2), fn -> "no value" end)
      # => "no value"

      iex> Option.match(Option.some("hello"), fn x -> String.upcase(x) end)
      "HELLO"

      iex> Option.match(Option.none(),  fn -> "nothing" end)
      "nothing"

      iex> Option.match(Option.some("hello"), fn x -> String.upcase(x) end, fn -> "nothing" end )
      "HELLO"

      iex> Option.match(Option.none(), fn x -> String.upcase(x) end,   fn -> "nothing" end)
      "nothing"

  """

  @spec match(option(), func()) :: tr()
  def match(%__MODULE__{value: @none}, none_fun) when is_function(none_fun, 0) do
    none_fun.()
  end

  @spec match(option(t), func(t)) :: tr()
  def match(%__MODULE__{value: value}, some_fun)
      when value != @none and is_function(some_fun, 1),
      do: some_fun.(value)

  @spec match(option(t) | option(), func(t), func()) :: tr()
  def match(%__MODULE__{value: value}, some_fun, none_fun)
      when is_function(some_fun, 1) and is_function(none_fun, 0) do
    case value != @none do
      true -> some_fun.(value)
      _ -> none_fun.()
    end
  end

  def match(_, _, _) do
    none()
  end

  ## match function region end

  ## some function region start
  @doc """
  Creates an `Option` in `Some` state

  ## Examples

      iex> Option.some("hello")
      %Option{value: "hello"}
  """
  @spec some(t) :: option(t)
  def some(value) when value != @none, do: %__MODULE__{value: value}

  ## some function region end

  ## none function region start
  @doc """
  Creates an `Option` in `None` state.

  ## Examples

      iex> Option.none()
      %Option{value: :nil}

  """
  @spec none() :: option()
  def none(), do: %__MODULE__{value: @none}

  ## none function region end
end
