defmodule Tipping.Repo.Migrations.SeedTeams do
  use Ecto.Migration

  @teams [
    %{
      name: "Mexico",
      fifa_code: "MEX",
      group: "A"
    },
    %{
      name: "Sør-Afrika",
      fifa_code: "RSA",
      group: "A"
    },
    %{
      name: "Sør-Korea",
      fifa_code: "KOR",
      group: "A"
    },
    %{
      name: "Tsjekkia",
      fifa_code: "CZE",
      group: "A"
    },
    %{
      name: "Canada",
      fifa_code: "CAN",
      group: "B"
    },
    %{
      name: "Bosnia-Hercegovina",
      fifa_code: "BIH",
      group: "B"
    },
    %{
      name: "Qatar",
      fifa_code: "QAT",
      group: "B"
    },
    %{
      name: "Sveits",
      fifa_code: "SUI",
      group: "B"
    },
    %{
      name: "Brasil",
      fifa_code: "BRA",
      group: "C"
    },
    %{
      name: "Marokko",
      fifa_code: "MAR",
      group: "C"
    },
    %{
      name: "Haiti",
      fifa_code: "HAI",
      group: "C"
    },
    %{
      name: "Skotland",
      fifa_code: "SCO",
      group: "C"
    },
    %{
      name: "USA",
      fifa_code: "USA",
      group: "D"
    },
    %{
      name: "Paraguay",
      fifa_code: "PAR",
      group: "D"
    },
    %{
      name: "Australia",
      fifa_code: "AUS",
      group: "D"
    },
    %{
      name: "Tyrkia",
      fifa_code: "TUR",
      group: "D"
    },
    %{
      name: "Tyskland",
      fifa_code: "GER",
      group: "E"
    },
    %{
      name: "Curaçao",
      fifa_code: "CUW",
      group: "E"
    },
    %{
      name: "Elfenbenskysten",
      fifa_code: "CIV",
      group: "E"
    },
    %{
      name: "Ecuador",
      fifa_code: "ECU",
      group: "E"
    },
    %{
      name: "Nederland",
      fifa_code: "NED",
      group: "F"
    },
    %{
      name: "Japan",
      fifa_code: "JPN",
      group: "F"
    },
    %{
      name: "Sverige",
      fifa_code: "SWE",
      group: "F"
    },
    %{
      name: "Tunisia",
      fifa_code: "TUN",
      group: "F"
    },
    %{
      name: "Belgia",
      fifa_code: "BEL",
      group: "G"
    },
    %{
      name: "Egypt",
      fifa_code: "EGY",
      group: "G"
    },
    %{
      name: "Iran",
      fifa_code: "IRN",
      group: "G"
    },
    %{
      name: "New Zealand",
      fifa_code: "NZL",
      group: "G"
    },
    %{
      name: "Spania",
      fifa_code: "ESP",
      group: "H"
    },
    %{
      name: "Kapp Verde",
      fifa_code: "CPV",
      group: "H"
    },
    %{
      name: "Saudi-Arabia",
      fifa_code: "KSA",
      group: "H"
    },
    %{
      name: "Uruguay",
      fifa_code: "URU",
      group: "H"
    },
    %{
      name: "Frankrike",
      fifa_code: "FRA",
      group: "I"
    },
    %{
      name: "Senegal",
      fifa_code: "SEN",
      group: "I"
    },
    %{
      name: "Irak",
      fifa_code: "IRQ",
      group: "I"
    },
    %{
      name: "Norge",
      fifa_code: "NOR",
      group: "I"
    },
    %{
      name: "Argentina",
      fifa_code: "ARG",
      group: "J"
    },
    %{
      name: "Algerie",
      fifa_code: "ALG",
      group: "J"
    },
    %{
      name: "Østerrike",
      fifa_code: "AUT",
      group: "J"
    },
    %{
      name: "Jordan",
      fifa_code: "JOR",
      group: "J"
    },
    %{
      name: "Portugal",
      fifa_code: "POR",
      group: "K"
    },
    %{
      name: "DR Kongo",
      fifa_code: "COD",
      group: "K"
    },
    %{
      name: "Usbekistan",
      fifa_code: "UZB",
      group: "K"
    },
    %{
      name: "Colombia",
      fifa_code: "COL",
      group: "K"
    },
    %{
      name: "England",
      fifa_code: "ENG",
      group: "L"
    },
    %{
      name: "Kroatia",
      fifa_code: "CRO",
      group: "L"
    },
    %{
      name: "Ghana",
      fifa_code: "GHA",
      group: "L"
    },
    %{
      name: "Panama",
      fifa_code: "PAN",
      group: "L"
    }
  ]

  def up do
    now = DateTime.utc_now(:second)
    rows = @teams |> Enum.map(&Map.merge(&1, %{inserted_at: now, updated_at: now}))
    repo().insert_all("teams", rows)
  end

  def down do
    repo().delete_all("teams")
  end
end
