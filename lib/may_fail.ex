defmodule Hike.MayFail do
  alias Hike.MayFail, as: MayFail
  @moduledoc """

  `Hike.MayFail` represents a value that may either succeed with a value or fail with
  an error.
  It combines the functionality of `Hike.Option` and `Hike.Either`,
  making it suitable for scenarios where a value can be optional and can
  also potentially fail.

  Creating a MayFail

  To create a `MayFail` instance, you can use the `Hike.MayFail.success/1`
  function to wrap a success value:

  ```elixir
  iex> may_fail = Hike.MayFail.success(42)
  %Hike.MayFail{failure: nil, success: 42, is_success?: true}
  iex> may_fail = Hike.MayFail.failure(:error)
  %Hike.MayFail{failure: :error, success: nil, is_success?: false}
  ```
  ```elixir
  # same example can be rewritten with `MayFail`
  # Define a User struct
  defmodule User do
  @derive Jason.Encoder
  defstruct [:id, :age, :name]
  end

  defmodule TestHike do
  # Import the Hike.MayFail module
  import Hike.MayFail

  # Simulating a database fetch function
  @spec fetch_user(number) :: Hike.MayFail.mayfail(String.t()) | Hike.MayFail.mayfail_success(%User{})
  def fetch_user(id) do
    # Simulating a database query to fetch a user by ID
    # Returns an MayFail<string, User> with success(user) if the user is found
    # Returns an MayFail<string, User> with failure("User not found") if the user is not found
    case id do
      1 -> success(%User{id: 1, age: 30, name: "Vineet Sharma"})
      2 -> success(%User{id: 2, age: 20, name: nil})
      _ -> failure("User not found")
    end
  end

  # Function to update the user's name to uppercase if possible
  # This function takes a User struct and returns an MayFail<string, User>
  def update_name_to_uppercase(user) do
  case user.name do
    nil -> failure("User name is missing")
    name -> success(%User{user | name: String.upcase(name)})
  end
  end

  # Function to increase the user's age by one
  # This function takes a User struct and returns a real data type User with updated values.
  def increase_age_by_1(user) do
    %User{user | age: user.age + 1}
  end

  # Function to print a user struct as a JSON-represented string
  def print_user_as_json(user) do
    user
    |> Jason.encode!()
    |> IO.puts()
  end

  @spec test_user() :: :ok
  def test_user() do
    fetch_user(1)
    |> bind_success(&update_name_to_uppercase/1)
    |> map_success(&increase_age_by_1/1)
    |> IO.inspect()
    |> match(&IO.puts/1, &print_user_as_json/1)

    fetch_user(2)
    |> bind_success(&update_name_to_uppercase/1)
    |> map_success(&increase_age_by_1/1)
    |> IO.inspect()
    |> match(&IO.puts/1, &print_user_as_json/1)

    fetch_user(3)
    |> bind_success(&update_name_to_uppercase/1)
    |> map_success(&increase_age_by_1/1)
    |> IO.inspect()
    |> match(&IO.puts/1, &print_user_as_json/1)

    :ok
  end
  end
  ```

  ```elixir
  iex> TestHike.test_user
  # user id =1
  %Hike.MayFail{
  failure: nil,
  success: %User{id: 1, age: 31, name: "VINEET SHARMA"},
  is_success?: true
  }
  {"age":31,"id":1,"name":"VINEET SHARMA"}

  # user id = 2

  %Hike.MayFail{failure: "User name is missing", success: nil, is_success?: false}
  User name is missing

  #user id = 3

  %Hike.MayFail{failure: "User not found", success: nil, is_success?: false}
  User not found
  :ok
  ```

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
  `func()` represent a function which take no argument and return value of type `<TR>`.
  """
  @type func :: (() -> tr)

  @typedoc """
  `func(t)` represent a function which take an argument of type `<T>`
  and return a value of type `<TR>`.
  """
  @type func(t) :: (t -> tr)

  @typedoc """
  `mapper()` represent a mapping function which take no argument and return
  a value of type `<TR>`.
  """
  @type mapper :: (() -> tr)

  @typedoc """
  `mapper(t)` represent a mapping function which take an argument of type `<T>`
  and return a value of type `<TR>`.
  """
  @type mapper(t) :: (t -> tr)

  @typedoc """
  `binder()` represent a binding(mapping) function which take no argument and
  return a Mayfail of type `<TR>`.

  ## Example
      iex> success_bind_func = fn () -> Hike.MayFail.success(:ok) end
      iex> failure_bind_func = fn () -> Hike.MayFail.failure(:error) end
  """
  @type binder :: (() -> mayfail_success(tr) | mayfail_failure(tr))

  @typedoc """
  `binder(t)` represent a binding(mapping) function which take an argument of type `<T>`
    and return a `Mayfail` of type `<TR>`.

  ## Example
      iex> success_bind_func = fn (x) -> Mayfail.success(x) end
      iex> failure_bind_func = fn (y) -> Mayfail.failure(y) end
  """
  @type binder(t) :: (t -> mayfail_success(tr) | mayfail_failure(tr))

  @typedoc """
    generic input type `<T_Failure>` represent a type of value on `Failure`state.
  """
  @type t_failure :: any()

  @typedoc """
  generic input type `<T_Success>`represent a type of value on `Success`state.
  """
  @type t_success :: any()

  @typedoc """
  represent a type of `Mayfail` that could be in either `failure` or `success` state
  with a value of given type.
  """
  @type mayfail(t_failure, t_success) :: %__MODULE__{
          failure: t_failure,
          success: t_success,
          is_success?: boolean()
        }
  @typedoc """
  represent a type of `Mayfail` that could be in either `Failure` or `Success` state
  """
  @opaque mayfail() :: %__MODULE__{
            failure: t_failure(),
            success: t_success(),
            is_success?: boolean()
          }
  @typedoc """
  Elevated data type of `Mayfail` struct that represents `Success` state.
  """
  @type mayfail_success :: %__MODULE__{
          failure: nil,
          success: t_success(),
          is_success?: true
        }
  @typedoc """
  Elevated data type of `Mayfail` struct that represents `Success` state and have a value of type `<T>`.
  """
  @type mayfail_success(t) :: %__MODULE__{
          failure: nil,
          success: t,
          is_success?: true
        }

  @typedoc """
  represent a type of `Mayfail` in `Failure` state.
  """
  @type mayfail_failure :: %__MODULE__{
          failure: t_failure(),
          success: nil,
          is_success?: false
        }
  @typedoc """
  represent a type of `Mayfail` in `Failure` state.
  """
  @type mayfail_failure(t) :: %__MODULE__{
          failure: t,
          success: nil,
          is_success?: false
        }
  @doc """
  `%Hike.Mayfail{failure: t_failure(), success: t_success(), is_success?:boolean()}` is a struct that represents an "either/or" value.
  It can contain either a `Failure` value or a `Success` value, but not both.

  * `failure`: the failure value (if `is_success?` is false)
  * `success`: the success value (if `is_success?` is true)
  * `is_success?`: a boolean flag indicating whether the value is a success value (`true`) or a failure value (`false`)
  """
  defstruct [:failure, :success, :is_success?]

  @spec success(t_success) :: mayfail_success(t_success)
  def success(value) when value != nil,
    do: %__MODULE__{success: value, failure: nil, is_success?: true}

  @spec failure(t_failure) :: mayfail_failure(t_failure)
  def failure(error) when error != nil,
    do: %__MODULE__{success: nil, failure: error, is_success?: false}

  @doc """

  ## Example

      iex> apply_func = fn x -> (x + 2) end
      iex> MayFail.failure(1) |> MayFail.apply_success(apply_func)
      %Hike.MayFail{failure: 1, success: nil, is_success?: false}

      iex> MayFail.success(1) |> MayFail.apply_success(apply_func)
      %Hike.MayFail{failure: nil, success: 3, is_success?: true}

  """
  @spec apply_success(mayfail_success(t_success()), func(t_success())) :: mayfail_success(tr())
  def apply_success(%__MODULE__{success: value, is_success?: true} = _mayfail, func)
      when is_function(func, 1) do
    func.(value) |> success
  end

  @spec apply_success(mayfail_failure(t_failure()), func(t_success())) ::
          mayfail_failure(t_failure())
  def apply_success(%__MODULE__{failure: error, is_success?: false} = _mayfail, _func),
    do: failure(error)

  @doc """

  ## Example

      iex> apply_func = fn x -> x + 2 end
      iex> MayFail.failure(1) |> MayFail.apply_failure(apply_func)
      %Hike.MayFail{failure: 3, success: nil, is_success?: false}

      iex> MayFail.success(1) |> MayFail.apply_failure(apply_func)
      %Hike.MayFail{failure: nil, success: 1, is_success?: true}


  """
  @spec apply_failure(mayfail_failure(t_failure()), func(t_failure())) :: mayfail_failure(tr())
  def apply_failure(%__MODULE__{failure: error, is_success?: false} = _mayfail, func)
      when is_function(func, 1),
      do: func.(error) |> failure

  @spec apply_failure(mayfail_success(t_success()), func(t_failure())) ::
          mayfail_success(t_success())
  def apply_failure(%__MODULE__{success: value, is_success?: true} = _mayfail, _func),
    do: success(value)

  @doc """

  ## Example

      iex> mapper = fn x -> (x + 2) end
      iex> MayFail.failure(1) |> MayFail.map_success(mapper)
      %Hike.MayFail{failure: 1, success: nil, is_success?: false}

      iex> MayFail.success(1) |> MayFail.map_success(mapper)
      %Hike.MayFail{failure: nil, success: 3, is_success?: true}

  """
  @spec map_success(mayfail_success(t_success()), mapper()) :: mayfail_success(tr())
  def map_success(%__MODULE__{success: value, is_success?: true} = _mayfail, mapper)
      when is_function(mapper, 1) do
    mapper.(value) |> success
  end

  @spec map_success(mayfail_failure(t_failure()), mapper(t_success())) ::
          mayfail_failure(t_failure())
  def map_success(%__MODULE__{failure: error, is_success?: false} = _mayfail, _mapper),
    do: failure(error)

  @doc """

  ## Example

      iex> mapper = fn x -> x + 2 end
      iex> MayFail.failure(1) |> MayFail.map_failure(mapper)
      %Hike.MayFail{failure: 3, success: nil, is_success?: false}

      iex> MayFail.success(1) |> MayFail.map_failure(mapper)
      %Hike.MayFail{failure: nil, success: 1, is_success?: true}


  """
  @spec map_failure(mayfail_failure(t_failure()), mapper(t_failure())) :: mayfail_failure(tr())
  def map_failure(%__MODULE__{failure: error, is_success?: false} = _mayfail, mapper)
      when is_function(mapper, 1),
      do: mapper.(error) |> failure

  @spec map_failure(mayfail_failure(t_success()), mapper(t_failure())) ::
          mayfail_failure(t_success())
  def map_failure(%__MODULE__{success: value, is_success?: true} = _mayfail, _mapper),
    do: success(value)

  @doc """
  Binds a function that returns a `MayFail` value for an `MayFail` in the `Failure` state.
  If the input is in the `Success` state, the function is not executed and the input is returned as it is.

  ## Example

      iex> binder = fn x -> MayFail.success(x + 2) end
      iex> MayFail.failure(1) |> MayFail.bind_success(binder)
      %Hike.MayFail{failure: 1, success: nil, is_success?: false}

      iex> MayFail.success(1) |> MayFail.bind_success(binder)
      %Hike.MayFail{failure: nil, success: 3, is_success?: true}

      iex> binder = fn x -> MayFail.failure(x + 2) end
      iex>  MayFail.success(1) |> MayFail.bind_success(binder)
      %Hike.MayFail{failure: 3, success: nil, is_success?: false}

  """
  @spec bind_success(mayfail_success(t_success()), binder(t_success())) :: mayfail_success(tr())
  def bind_success(%__MODULE__{success: value, is_success?: true} = _mayfail, binder)
      when is_function(binder, 1),
      do: binder.(value)

  @spec bind_success(mayfail_failure(t_failure()), binder(t_success())) ::
          mayfail_failure(t_failure)
  def bind_success(%__MODULE__{failure: error, is_success?: false} = _mayfail, _binder),
    do: failure(error)

  @doc """
  Binds a function that returns a `MayFail` value for an `MayFail` in the `Failure` state.
  If the input is in the `Success` state, the function is not executed and the input is returned as it is.

  ## Example

      iex> binder = fn x -> MayFail.success(x + 2) end
      iex> MayFail.failure(1) |> MayFail.bind_failure(binder)
      %Hike.MayFail{failure: nil, success: 3, is_success?: true}

      iex> binder = fn x -> MayFail.failure(x + 2) end
      iex>  MayFail.failure(1) |> MayFail.bind_failure(binder)
      %Hike.MayFail{failure: 3, success: nil, is_success?: false}

      iex> MayFail.success(1) |> MayFail.bind_failure(binder)
      %Hike.MayFail{failure: nil, success: 1, is_success?: true}


  """

  @spec bind_failure(mayfail_failure(t_failure()), binder(t_failure())) :: mayfail_failure(tr())
  def bind_failure(%__MODULE__{failure: error, is_success?: false} = _mayfail, binder)
      when is_function(binder, 1),
      do: binder.(error)

  @spec bind_failure(mayfail_failure(t_success()), binder(t_failure())) ::
          mayfail_failure(t_success())
  def bind_failure(%__MODULE__{success: value, is_success?: true} = _mayfail, _binder),
    do: success(value)

  @doc """

  Matches an `Mayfail` value and applies the corresponding function.

  ## Example

      iex> Hike.MayFail.success(4) |> Hike.MayFail.match(fn x -> x + 3 end, fn y -> y + 2 end)
      6
  """

  @spec match(
          MayFail.mayfail(t_failure(), t_success()),
          (t_failure() -> tr()),
          (t_success() -> tr())
        ) :: tr()
  def match(%__MODULE__{failure: x, is_success?: false} = _mayfail, failure_fn, _)
      when is_function(failure_fn, 1),
      do: failure_fn.(x)

  def match(%__MODULE__{success: x, is_success?: true} = _mayfail, _, success_fn)
      when is_function(success_fn, 1),
      do: success_fn.(x)

  @doc """
  Check whether MayFail is in `Success` state or not.

  ## Example
      iex> Hike.MayFail.success(4) |> Hike.MayFail.is_success?
      true
      iex> Hike.MayFail.failure("fail") |> Hike.MayFail.is_success?
      false
  """

  @spec is_success?(mayfail_success()) :: true
  def is_success?(%__MODULE__{is_success?: true} = _mayfail), do: true
  @spec is_success?(mayfail_failure()) :: false
  def is_success?(_), do: false

  @doc """
  Check whether MayFail is in `Failure` state or not.

  ## Example

      iex> Hike.MayFail.success(4) |> Hike.MayFail.is_failure?
      false
      iex> Hike.MayFail.failure("fail") |> Hike.MayFail.is_failure?
      true
  """
  @spec is_failure?(mayfail_failure()) :: true
  def is_failure?(%__MODULE__{is_success?: false} = _mayfail), do: true
  @spec is_failure?(mayfail_success()) :: false
  def is_failure?(_), do: false
end
