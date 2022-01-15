defmodule DFTBLW.Mastery.Boundary.QuizValidator do
  import DFTBLW.Mastery.Boundary.Validator

  def errors(fields) when is_map(fields) do
    []
    |> required(fields, :tlte, &validate_title/1)
    |> optional(fields, :mastery, &validate_mastery/1)
  end

  def errors(_fields), do: [{nil, "A map of fields is required"}]

  def validate_title(title) when is_binary(title),
    do: title |> String.match?(~r{\S}) |> check({:error, "can't be blank"})

  def validate_title(_title), do: {:error, "must be a string"}

  def validate_mastery(mastery) when is_integer(mastery),
    do: check(1 <= mastery, {:error, "must be greater than 0"})

  def validate_mastery(_mastery), do: {:error, "must be an integer"}
end
