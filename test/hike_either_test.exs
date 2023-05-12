defmodule HikeEitherTest do
  alias Hike.Either, as: Either
  use ExUnit.Case

  test "create an Either in right state" do
    r_eth = Either.right(4)
    assert r_eth == %Hike.Either{l_value: nil, r_value: 4, is_left?: false}
  end

  test "create an Either in left state" do
    l_eth = Either.left("hello")
    assert l_eth == %Hike.Either{l_value: "hello", r_value: nil, is_left?: true}
  end

  test "apply_right function on right side Either" do
    r_eth = Either.right(4)
    func = fn x -> x + 2 end
    app_r_eth = Either.apply_right(r_eth, func)
    assert app_r_eth == %Either{l_value: nil, r_value: 6, is_left?: false}
  end

  test "apply_right function on left side Either" do
    l_eth = Either.left("hello")
    func = fn x -> String.upcase(x) end
    app_r_eth = Either.apply_right(l_eth, func)
    assert app_r_eth == %Either{l_value: "hello", r_value: nil, is_left?: true}
  end

  test "apply_left function on left side Either" do
    l_eth = Either.left("hello")
    func = fn x -> String.upcase(x) end
    app_l_eth = Either.apply_left(l_eth, func)
    assert app_l_eth == %Either{l_value: "HELLO", r_value: nil, is_left?: true}
  end

  test "apply_left function on right side Either" do
    r_eth = Either.right(5)
    func = fn x -> x + 1 end
    app_l_eth = Either.apply_left(r_eth, func)
    assert app_l_eth == %Either{l_value: nil, r_value: 5, is_left?: false}
  end

  test "map_right function on right side Either" do
    r_eth = Either.right(4)
    func = fn x -> x + 2 end
    app_r_eth = Either.map_right(r_eth, func)
    assert app_r_eth == %Either{l_value: nil, r_value: 6, is_left?: false}
  end

  test "map_right function on left side Either" do
    l_eth = Either.left("hello")
    func = fn x -> String.upcase(x) end
    app_r_eth = Either.map_right(l_eth, func)
    assert app_r_eth == %Either{l_value: "hello", r_value: nil, is_left?: true}
  end

  test "map_left function on left side Either" do
    l_eth = Either.left("hello")
    func = fn x -> String.upcase(x) end
    app_l_eth = Either.map_left(l_eth, func)
    assert app_l_eth == %Either{l_value: "HELLO", r_value: nil, is_left?: true}
  end

  test "map_left function on right side Either" do
    r_eth = Either.right(5)
    func = fn x -> x + 1 end
    app_l_eth = Either.map_left(r_eth, func)
    assert app_l_eth == %Either{l_value: nil, r_value: 5, is_left?: false}
  end

  test "bind_right function on right side Either with right state back" do
    r_eth = Either.right(4)
    func = fn x -> Either.right(x + 2) end
    app_r_eth = Either.bind_right(r_eth, func)
    assert app_r_eth == %Either{l_value: nil, r_value: 6, is_left?: false}
  end

  test "bind_right function on right side Either with left state back" do
    val = 4
    r_eth = Either.right(val)
    func = fn x -> Either.left("Either value is #{x}") end
    app_r_eth = Either.bind_right(r_eth, func)
    assert app_r_eth == %Either{l_value: "Either value is #{val}", r_value: nil, is_left?: true}
  end

  test "bind_right function on left side Either" do
    l_eth = Either.left("hello")
    func = fn x -> String.upcase(x) |> Either.left() end
    app_r_eth = Either.bind_right(l_eth, func)
    assert app_r_eth == %Either{l_value: "hello", r_value: nil, is_left?: true}
  end

  test "bind_left function on left side Either with left state back" do
    l_eth = Either.left("hello")
    func = fn x -> Either.left(String.upcase(x)) end
    app_l_eth = Either.bind_left(l_eth, func)
    assert app_l_eth == %Either{l_value: "HELLO", r_value: nil, is_left?: true}
  end

  test "bind_left function on left side Either with right state back" do
    val = "hello"
    l_eth = Either.left(val)
    func = fn x -> Either.right(String.length(x)) end
    app_l_eth = Either.bind_left(l_eth, func)
    assert app_l_eth == %Either{l_value: nil, r_value: 5, is_left?: false}
  end

  test "bind_left function on right side Either" do
    r_eth = Either.right(5)
    func = fn x -> (x * x) |> Either.right() end
    app_l_eth = Either.bind_left(r_eth, func)
    assert app_l_eth == %Either{l_value: nil, r_value: 5, is_left?: false}
  end

  test "match function match Either state and call respective function." do
    l_func = fn _x -> "Either is in left state" end
    r_func = fn x -> "Either is in right state: #{x}" end
    assert "Either is in left state" == Either.match(Either.left("hello"), l_func, r_func)
    assert "Either is in right state: 5" == Either.match(Either.right(5), l_func, r_func)
  end

  test "from result" do
    assert Either.from_result({:ok, 5})
           |> Either.match(fn x -> x + 1 end, fn x -> x end) == 5

    assert Either.from_result({:error, "data not found"})
           |> Either.match(fn x -> x end, fn x -> x + 3 end) == "data not found"
  end
end
