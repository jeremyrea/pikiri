defmodule Pikiri.Uploaders.PhotoUploader do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  # To add a thumbnail version:
  # @versions [:original, :thumb]
  @versions [:original, :jpeg]
  @extension_whitelist ~w(.jpg .jpeg .png)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()

    case Enum.member?(@extension_whitelist, file_extension) do
      true -> :ok
      false -> {:error, "invalid file type"}
    end
  end

  def crop_cmd(mask) do
    "-strip -crop #{mask["width"]}x#{mask["height"]}+#{mask["x"]}+#{mask["y"]} +repage"
  end

  def transform(:jpeg, {_file, scope}), do: {:convert, "#{crop_cmd(scope.mask)} -format jpeg", :jpeg}
  def uuid(file), do: file.file_name |> Path.basename(Path.extname(file.file_name))

  def filename(:original, {file, _scope}), do: uuid(file)
  def filename(_version, {file, _scope}), do: uuid(file)

  defp base_dir(), do:  Path.join([Application.get_env(:pikiri, :uploads_directory), "posts"])

  def storage_dir(:original, {_file, _scope}), do: Path.join([base_dir(), "originals"])
  def storage_dir(_version, {file, _scope}), do: Path.join([base_dir(), "public", uuid((file))])
end
