defmodule TippingWeb.PointsTableComponents do
  @moduledoc """
  Components for the user standings page.
  """

  use Phoenix.Component

  attr :scores, :list, required: true

  def scoreboard(assigns) do
    ~H"""
    <ol class="grid gap-0.5">
      <li
        :for={row <- @scores}
        class={[
          "flex justify-between py-3 px-5 bg-[#27308366]",
          "first:rounded-tr-[20px]",
          "last:rounded-bl-[20px]"
        ]}
      >
        <div class="flex gap-2.5 min-w-0">
          <span class="opacity-60 inline-block w-[2ch] text-right">{row.position}</span>
          <span class="truncate">{row.name}</span>
        </div>
        <span>{row.points}</span>
      </li>
    </ol>
    """
  end
end
