defmodule DFTBLW.Mastery.Boundary.Validator do
  def required(errors, fields, field_name, validator) do
    present = Map.has_key?(fields, field_name)

    check_required_field(present, fields, errors, field_name, validator)
  end

  def optional(errors, fields, field_name, validator) do
    if Map.has_key?(fields, field_name),
      do: required(errors, fields, field_name, validator),
      else: errors
  end

  def check(valid, message)
  def check(true, _message), do: :ok
  def check(false, message), do: message

  defp check_required_field(true, fields, errors, field_name, f) do
    valid = fields |> Map.fetch!(field_name) |> f.()

    check_field(valid, errors, field_name)
  end

  defp check_required_field(_present, _fields, errors, field_name, _f) do
    errors ++ [{field_name, "is required"}]
  end

  defp check_field(:ok, _errors, _field_name), do: :ok
  defp check_field({:error, message}, errors, field_name), do: errors ++ [{field_name, message}]

  defp check_field({:errors, messages}, errors, field_name),
    do: errors ++ Enum.map(messages, &{field_name, &1})
end
