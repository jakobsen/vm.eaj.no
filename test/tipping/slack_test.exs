defmodule Tipping.SlackTest do
  use ExUnit.Case, async: true

  alias Tipping.Slack

  describe "format_message/1" do
    test "formats the given scores as a Slack JSON payload" do
      result =
        Slack.format_message("God morgen!", [
          %{position: 1, name: "Amalie Skrede", points: 11},
          %{position: 2, name: "Erik André Jakobsen", points: 9}
        ])

      assert result == %{
               blocks: [
                 %{
                   type: "section",
                   text: %{
                     type: "plain_text",
                     text: "God morgen!",
                     emoji: true
                   }
                 },
                 %{
                   type: "data_table",
                   caption: "Aidn standings",
                   page_size: 10,
                   rows: [
                     [
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
                     ],
                     [
                       %{
                         type: "raw_number",
                         value: 1,
                         text: "1"
                       },
                       %{
                         type: "raw_text",
                         text: "Amalie Skrede"
                       },
                       %{
                         type: "raw_number",
                         value: 11,
                         text: "11"
                       }
                     ],
                     [
                       %{
                         type: "raw_number",
                         value: 2,
                         text: "2"
                       },
                       %{
                         type: "raw_text",
                         text: "Erik André Jakobsen"
                       },
                       %{
                         type: "raw_number",
                         value: 9,
                         text: "9"
                       }
                     ]
                   ]
                 }
               ]
             }
    end
  end
end
