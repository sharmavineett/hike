defmodule HikeMayFailTest do
  alias Hike.MayFail, as: MayFail
  use ExUnit.Case

  test "create an MayFail in success state" do
    r_eth = MayFail.success(4)
    assert r_eth == %Hike.MayFail{failure: nil, success: 4, is_success?: true}
  end

  test "create an MayFail in failure state" do
    l_eth = MayFail.failure("hello")
    assert l_eth == %Hike.MayFail{failure: "hello", success: nil, is_success?: false}
  end

  test "apply_success function on success side MayFail" do
    r_eth = MayFail.success(4)
    func = fn x -> x + 2 end
    app_r_eth = MayFail.apply_success(r_eth, func)
    assert app_r_eth == %MayFail{failure: nil, success: 6, is_success?: true}
  end

  test "apply_success function on failure side MayFail" do
    l_eth = MayFail.failure("hello")
    func = fn x -> String.upcase(x) end
    app_r_eth = MayFail.apply_success(l_eth, func)
    assert app_r_eth == %MayFail{failure: "hello", success: nil, is_success?: false}
  end

  test "apply_failure function on failure side MayFail" do
    l_eth = MayFail.failure("hello")
    func = fn x -> String.upcase(x) end
    app_l_eth = MayFail.apply_failure(l_eth, func)
    assert app_l_eth == %MayFail{failure: "HELLO", success: nil, is_success?: false}
  end

  test "apply_failure function on success side MayFail" do
    r_eth = MayFail.success(5)
    func = fn x -> x + 1 end
    app_l_eth = MayFail.apply_failure(r_eth, func)
    assert app_l_eth == %MayFail{failure: nil, success: 5, is_success?: true}
  end

  test "map_success function on success side MayFail" do
    r_eth = MayFail.success(4)
    func = fn x -> x + 2 end
    app_r_eth = MayFail.map_success(r_eth, func)
    assert app_r_eth == %MayFail{failure: nil, success: 6, is_success?: true}
  end

  test "map_success function on failure side MayFail" do
    l_eth = MayFail.failure("hello")
    func = fn x -> String.upcase(x) end
    app_r_eth = MayFail.map_success(l_eth, func)
    assert app_r_eth == %MayFail{failure: "hello", success: nil, is_success?: false}
  end

  test "map_failure function on failure side MayFail" do
    l_eth = MayFail.failure("hello")
    func = fn x -> String.upcase(x) end
    app_l_eth = MayFail.map_failure(l_eth, func)
    assert app_l_eth == %MayFail{failure: "HELLO", success: nil, is_success?: false}
  end

  test "map_failure function on success side MayFail" do
    r_eth = MayFail.success(5)
    func = fn x -> x + 1 end
    app_l_eth = MayFail.map_failure(r_eth, func)
    assert app_l_eth == %MayFail{failure: nil, success: 5, is_success?: true}
  end

  test "bind_success function on success side MayFail with success state back" do
    r_eth = MayFail.success(4)
    func = fn x -> MayFail.success(x + 2) end
    app_r_eth = MayFail.bind_success(r_eth, func)
    assert app_r_eth == %MayFail{failure: nil, success: 6, is_success?: true}
  end

  test "bind_success function on success side MayFail with failure state back" do
    val = 4
    r_eth = MayFail.success(val)
    func = fn x -> MayFail.failure("MayFail value is #{x}") end
    app_r_eth = MayFail.bind_success(r_eth, func)

    assert app_r_eth == %MayFail{
             failure: "MayFail value is #{val}",
             success: nil,
             is_success?: false
           }
  end

  test "bind_success function on failure side MayFail" do
    l_eth = MayFail.failure("hello")
    func = fn x -> String.upcase(x) |> MayFail.failure() end
    app_r_eth = MayFail.bind_success(l_eth, func)
    assert app_r_eth == %MayFail{failure: "hello", success: nil, is_success?: false}
  end

  test "bind_failure function on failure side MayFail with failure state back" do
    l_eth = MayFail.failure("hello")
    func = fn x -> MayFail.failure(String.upcase(x)) end
    app_l_eth = MayFail.bind_failure(l_eth, func)
    assert app_l_eth == %MayFail{failure: "HELLO", success: nil, is_success?: false}
  end

  test "bind_failure function on failure side MayFail with success state back" do
    val = "hello"
    l_eth = MayFail.failure(val)
    func = fn x -> MayFail.success(String.length(x)) end
    app_l_eth = MayFail.bind_failure(l_eth, func)
    assert app_l_eth == %MayFail{failure: nil, success: 5, is_success?: true}
  end

  test "bind_failure function on success side MayFail" do
    r_eth = MayFail.success(5)
    func = fn x -> (x * x) |> MayFail.success() end
    app_l_eth = MayFail.bind_failure(r_eth, func)
    assert app_l_eth == %MayFail{failure: nil, success: 5, is_success?: true}
  end

  test "match function match MayFail state and call respective function." do
    l_func = fn _x -> "MayFail is in failure state" end
    r_func = fn x -> "MayFail is in success state: #{x}" end

    assert "MayFail is in failure state" ==
             MayFail.match(MayFail.failure("hello"), l_func, r_func)

    assert "MayFail is in success state: 5" == MayFail.match(MayFail.success(5), l_func, r_func)
  end
end
