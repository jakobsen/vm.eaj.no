defmodule Tipping.Repo.Migrations.AlterTeamsUseHyphenForCdi do
  use Ecto.Migration

  def up do
    execute """
    UPDATE teams SET name = 'Elfenbens-kysten'
    WHERE name LIKE 'Elfenbenskysten'
    """
  end

  def down do
    execute """
    UPDATE teams SET name = 'Elfenbenskysten'
    WHERE name LIKE 'Elfenbens-kysten'
    """
  end
end
