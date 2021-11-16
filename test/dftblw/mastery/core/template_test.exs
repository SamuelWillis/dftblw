defmodule DFTBLW.Mastery.Core.TemplateTest do
  use ExUnit.Case, async: true
  use QuizBuilders

  alias DFTBLW.Mastery.Core.Template

  describe "new/1" do
    test "builds template from fields" do
      fields = template_fields()

      assert %Template{} = template = Template.new(fields)

      assert fields
             |> Keyword.get(:compiled)
             |> is_nil()

      raw = Keyword.get(fields, :raw)

      assert template.compiled == EEx.compile_string(raw)
    end
  end
end
