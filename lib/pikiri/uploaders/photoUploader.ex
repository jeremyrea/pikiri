defmodule Pikiri.Uploaders.PhotoUploader do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  # To add a thumbnail version:
  # @versions [:original, :thumb]
  @versions [:original]
  @extension_whitelist ~w(.jpg .jpeg .png)

  # Whitelist file extensions:
  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
  
    case Enum.member?(@extension_whitelist, file_extension) do
      true -> :ok
      false -> {:error, "invalid file type"}
    end
  end

  def filename(version, _) do
    version
  end
end