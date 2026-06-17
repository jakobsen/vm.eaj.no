defmodule Tipping.Slack do
  @moduledoc """
  Functions for interacting with Slack.
  """

  @greetings [
    "¡Buenos días!",
    "Goeiemôre!",
    "좋은 아침이에요!",
    "Dobré ráno!",
    "Good morning!",
    "Dobro jutro!",
    "صباح الخير!",
    "Guete Morge!",
    "Bom dia!",
    "Bonjou!",
    "Madainn mhath!",
    "Günaydın!",
    "Guten Morgen!",
    "Bon dia!",
    "Bonjour!",
    "Goedemorgen!",
    "おはよう！",
    "God morgon!",
    "صبح بخیر!",
    "Jàmm nga fanaane?",
    "God morgen!",
    "Xayrli tong!"
  ]

  def send_message(message, channel, token) do
    Req.post("https://slack.com/api/chat.postMessage",
      json: Map.put(message, :channel, channel),
      headers: %{Authorization: "Bearer #{token}"}
    )
  end

  def format_message(greeting, standings) do
    %{
      blocks: [
        header(greeting),
        formatted_points_table(standings)
      ]
    }
  end

  def random_greeting() do
    Enum.random(@greetings)
  end

  defp header(greeting) do
    %{
      type: "section",
      text: %{
        type: "plain_text",
        text: greeting,
        emoji: true
      }
    }
  end

  defp formatted_points_table(standings) do
    header = [
      %{
        type: "raw_text",
        text: "Position"
      },
      %{
        type: "raw_text",
        text: "Name"
      },
      %{
        type: "raw_text",
        text: "Points"
      }
    ]

    rows =
      Enum.map(standings, fn row ->
        [
          %{
            type: "raw_number",
            value: row.position,
            text: format_position(row)
          },
          %{
            type: "raw_text",
            text: row.name
          },
          %{
            type: "raw_number",
            value: row.points,
            text: format_points(row)
          }
        ]
      end)

    %{
      type: "data_table",
      caption: "Aidn standings",
      page_size: 10,
      rows: [header | rows]
    }
  end

  defp format_position(%{position: position, previous_position: previous_position}) do
    cond do
      position > previous_position -> "#{position} (▿#{position - previous_position})"
      previous_position > position -> "#{position} (▵#{previous_position - position})"
      true -> "#{position} (–)"
    end
  end

  defp format_points(%{points: points, previous_points: previous_points}) do
    "#{points} (+#{points - previous_points})"
  end
end
