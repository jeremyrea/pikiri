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

  def filename(_version, {file, _scope}) do
    file.file_name |> Path.basename(Path.extname(file.file_name))
  end

  def storage_dir(_version, {_file, _scope}), do: storage_dir()
  def storage_dir(), do: Path.join([Application.get_env(:pikiri, :uploads_directory), "posts"])
end
