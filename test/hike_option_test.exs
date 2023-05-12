defmodule HikeOptionTest do
  alias Hike.Option, as: Option
  use ExUnit.Case

  test "mapping over an Option struct containing an integer" do
    assert Option.map(%Option{value: 4}, &(&1 * 2)) == %Option{value: 8}
  end

  test "mapping over an Option struct containing a string" do
    assert Option.map(%Option{value: "hello"}, &String.length/1) == %Option{value: 5}
  end

  test "mapping over an Option struct containing :none" do
    assert Option.map(%Option{value: :none}, & &1) == %Option{value: :none}
  end

  test "mapping over an Option struct containing a list of integers" do
    assert Option.map(%Option{value: [1, 2, 3]}, &Enum.sum/1) == %Option{value: 6}
  end
end
