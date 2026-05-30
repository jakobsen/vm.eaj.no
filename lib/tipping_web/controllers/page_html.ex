defmodule TippingWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use TippingWeb, :html

  import TippingWeb.HomeComponents

  alias TippingWeb.Layouts

  embed_templates "page_html/*"
end
