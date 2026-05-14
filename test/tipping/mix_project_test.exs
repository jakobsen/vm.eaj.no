defmodule Tipping.MixProjectTest do
  use ExUnit.Case, async: true

  test "deps are in sorted order" do
    deps = Keyword.fetch!(Tipping.MixProject.project(), :deps)
    sorted_deps = Enum.sort_by(deps, fn dep -> dep |> elem(0) |> Atom.to_string() end)
    assert deps == sorted_deps
  end
end
