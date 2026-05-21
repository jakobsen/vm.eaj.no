defmodule TippingWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use TippingWeb, :html

  import TippingWeb.HomeComponents

  embed_templates "page_html/*"

  attr :label, :string, required: true
  attr :points, :integer, required: true

  defp rule_row(assigns) do
    ~H"""
    <li class="flex justify-between bg-gray-100 rounded px-3 py-2 border border-gray-300">
      <span>{@label}</span>
      <span class="font-semibold">{@points} poeng</span>
    </li>
    """
  end
end
