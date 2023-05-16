
# Introduction

Welcome to the documentation for Hike, an Elixir library that provides elevated data types to
handle common scenarios like optional values, either values, and values that may fail.
Hike aims to make it easier and more expressive to work with these types,
enhancing the readability and robustness of your Elixir code.


## Hike
The `Hike` module provides an implementation of the elevated data types.
It defines

* a struct `Hike.Option` with a single field `value` which can either be `nil`
  or any other value of type `t`.

* a struct `Hike.Either` that represents an "either/or" value.
  It can contain either a `left` value or a `right` value, but not both

* a struct `Hike.MayFail`that represents an "either/or" value.
  It can contain either a `Failure` value or a `Success` value, but not both.

This implementation provides shorthand functions to work with Optional data, including mapping, filtering, applying and many more functions to the value
inside the Optional data.

## Why Hike?

The Hike library introduces elevated data types (`Option`, `Either`, and `MayFail`) and 
provides accompanying functions to work with these types in Elixir. 
The primary motivation behind using Hike is to handle scenarios where values can be optional,
represent success or failure, or have multiple possible outcomes.

Here are a few reasons why you may choose to use Hike in your Elixir projects:

1. **Expressiveness:** Hike enhances the expressiveness of your code by providing dedicated types (`Option`, `Either`, and `MayFail`) that convey the intent and semantics of your data. Instead of relying on traditional approaches like using `nil`, tuples, or exceptions, Hike's elevated data types provide a more intuitive and descriptive way to represent optional, success/failure, or multi-outcome values.

2. **Safer and more predictable code:** By using Hike's elevated data types, you can explicitly handle scenarios where values may be absent (`Option`), represent success or failure (`Either`), or have multiple possible outcomes (`MayFail`). This approach encourages you to handle all possible cases, reducing the chances of unexpected errors or unintended behavior. Hike provides functions to work with these types in a safe and predictable manner, promoting robust error handling and code clarity.

3. **Functional programming paradigm:** Hike aligns well with the functional programming paradigm by providing functional constructs like `map`, `bind`, and `apply`. These functions allow you to transform, chain, and apply computations to values of elevated types, promoting immutability and composability. The functional approach helps in writing concise, modular, and reusable code.

4. **Pattern matching and error handling:** Hike incorporates pattern matching to handle the different outcomes of elevated data types. With pattern matching, you can easily extract and work with the underlying values or apply different logic based on the specific outcome. Hike's functions, such as `match` and `orElse`, enable precise error handling and result evaluation, enhancing the control flow and readability of your code.

5. **Enhanced documentation and understanding:** By using Hike, you make the intent and behavior of your code more explicit. Elevated data types convey the possibilities and constraints of your data upfront, making it easier for other developers to understand and reason about your code. Additionally, Hike's functions have clear specifications and type signatures, enabling better documentation and static type checking tools.

Overall, Hike provides a set of elevated data types and functions that facilitate more expressive, safer, and predictable code, especially in scenarios where values can be optional, represent success/failure, or have multiple possible outcomes. By leveraging Hike, you can enhance the clarity, maintainability, and robustness of your Elixir codebase.


## Table of Contents

- Installation
- Usage
- - Hike.Option
- - Hike.Either
- - Hike.MayFail
- Examples
- Contributing
- License


### Installation 

To use Hike in your Elixir project, you can add it as a dependency in your mix.exs file:


```elixir
def deps do
  [
    {:hike, "~> 0.0.2"}
  ]
end
```
After adding the dependency, run `mix deps.get` to fetch and compile the library.
### Usage

Hike provides three elevated data types: 
* Hike.Option, 
* Hike.Either, and 
* Hike.MayFail. 

    Let's explore each type and its usage.

#### Hike.Option
`Hike.Option` represents an optional value, where the value may exist or may not exist. 
It is useful in scenarios where a function can return nil or an actual value,
and you want to handle that gracefully without resorting to conditional statements.

##### Creating an Option

To create an Option instance, 
you can use the Hike.Option.some/1 function to wrap a value:

```elixir
# Option in `some` state.
iex> Hike.Option.some(20)
%Hike.Option{value: 20}

# Option in `none` state.
iex> Hike.Option.none()
%Hike.Option{value: nil}

# we also have shorthand functions available in `Hike` module itself.
iex> Hike.option(20)
%Hike.Option{value: 20}

iex>Hike.option()
%Hike.Option{value: nil}

iex> Hike.option({:ok, 20})
%Hike.Option{value: 20}
# This one is intentional to ignore error msg. if you care about error msg 
# then we have `Hike.Either` and `Hike.MayFail`. where we do care about error as well.
# for more check respective explanation.
iex>Hike.option({:error, "error msg."})
%Hike.Option{value: nil}

```
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

1. #### Expressiveness: 
    The `fetch_user/1` function returns an `Option<User>`, indicating the possibility of a user not being found in the database. 
The `update_name_to_uppercase/1` function uses the Option type to ensure the updated name is wrapped in an Option as well.

2. #### Safer and more predictable code: 
    Both cases where the user is found and where the user is not found are explicitly handled using bind/2 and map/2 operations. This ensures that all possible cases are accounted for, promoting safer and more predictable code.
3. #### Functional programming paradigm:
    The functions `bind/2` and `map/2` are functional constructs provided by Hike.
They allow for composability and transformation of values. 
The `bind/2` function is used to transform and chain operations,
while the `map/2` function is used to transform the value within the Option type.

4. #### Pattern matching and error handling: 
    The `match/3` function is used to pattern match the result of the operations.
It allows for different logic to be applied based on whether a user is found or not. 
In the example, the `match/3` function is used to either print the user as a JSON string or display a "User not found" message.
5. #### Enhanced documentation and understanding: 
    The code structure and function names are chosen to convey the intent and behavior clearly. 
The use of elevated data types, such as Option, and explicit handling of possible cases make the code more self-documenting. 
Other developers can easily understand the possibilities and constraints of the data and follow the control flow.

By incorporating these five points, the code with Hike demonstrates how it improves expressiveness, code safety, adherence to functional programming principles, error handling, and code comprehension. It showcases the benefits of using Hike's elevated data types and functions for handling optional values and multiple outcomes in a concise and intuitive manner.

#### Hike.Either 
`Hike.Either` represents a value that can be one of two possibilities: either a `left` state or a `right` state.
It is commonly used in error handling or when a function can return different types of 
results.

##### Creating an Either

To create an Either instance, 
you can use the `Hike.Either.right/1` and `Hike.Either.left/1` function to wrap a value in 
`right` and `left` state respectively :

```elixir
iex> Hike.Either.right(5)
%Hike.Either{l_value: nil, r_value: 5, is_left?: false}
```
```elixir
# same example can be rewritten with `Either`
# Define a User struct
defmodule User do
  @derive Jason.Encoder
  defstruct [:id, :age, :name]
end
defmodule TestHike do
  # Import the Hike.Either module
  import Hike.Either

  # Simulating a database fetch function
  @spec fetch_user(number) :: Hike.Either.either(%User{}) | Hike.Either.either(String.t())
  def fetch_user(id) do
    # Simulating a database query to fetch a user by ID
    # Returns an Either<User, string> with left(user) if the user is found
    # Returns an Either<User, string> with right("User not found") if the user is not found
    case id do
      1 -> left(%User{id: 1, age: 30, name: "Vineet Sharma"})
      2 -> left(%User{id: 2, age: 20, name: "Jane Smith"})
      _ -> right("User not found")
    end
  end

# Function to update the user's name to uppercase if possible
# This function takes a User struct and returns an Either<User, string>
def update_name_to_uppercase(user) do
  case user.name do
    nil -> right("User name is missing")
    name ->  left(%User{user | name: String.upcase(name)})
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

  # Example: Fetching a user from the database, updating the name, and matching the result
  def test_user() do
    user_id = 1

    # Fetch the user from the database
    fetch_user(user_id)
    # Update the name to uppercase using bind
    |> bind_left(&update_name_to_uppercase/1)
    # Increase the age by one using map
    |> map_left(&increase_age_by_1/1)
    # Print the user as a JSON string using map
    |> map_left(&print_user_as_json/1)
    # finally match the respective result with a appropriate function.
    |> match(fn x -> x end, fn err ->err end)

    user_id = 3

    # Fetch the user from the database
    fetch_user(user_id)
    # Update the name to uppercase using bind
    |> bind_left(&update_name_to_uppercase/1)
    # Increase the age by one using map
    |> map_left(&increase_age_by_1/1)
    # Print the user as a JSON string using map
    |> map_left(&print_user_as_json/1)
    # finally match the respective result with a appropriate function.
    |> match(fn x -> x end, fn err -> err end)
  end
end

```
```shell
#output 
iex> TestHike.test_user
#user_id = 1
    {"age":31,"id":1,"name":"VINEET SHARMA"}
#user_id = 3
    "User not found"
```
#### Hike.MayFail 

`Hike.MayFail` represents a value that may either succeed with a value or fail with 
an error. 
It combines the functionality of `Hike.Option` and `Hike.Either`, 
making it suitable for scenarios where a value can be optional and can 
also potentially fail.

#### Creating a MayFail

To create a `MayFail` instance, you can use the `Hike.MayFail.success/1` 
function to wrap a success value:

```elixir
iex> may_fail = Hike.MayFail.success(42)
%Hike.MayFail{failure: nil, success: 42, is_success?: true}
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

```shell
#output 
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

### Contributing

Thank you for considering contributing to Hike! If you find any issues,
have suggestions, or want to contribute enhancements,
please feel free to open an issue or submit a pull request on the
GitHub repository.

License <a name="license"></a>

Hike is licensed under the MIT License. Feel free to use, modify, and distribute it according to the terms of the license.
Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). the docs can
be found at <https://hexdocs.pm/hike>.

