defmodule DFTBLW.Repo.Migrations.CreateResponses do
  use Ecto.Migration

  def change do
    create table(:responses) do
      add(:quiz_title, :string, null: false)
      add(:template_name, :string, null: false)
      add(:to, :string, null: false)
      add(:email, :string, null: false)
      add(:answer, :string, null: false)
      add(:correct, :string, null: false)

      timestamps()
    end

    create(index(:responses, :email))
  end
end
