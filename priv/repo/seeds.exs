# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Pikiri.Repo.insert!(%Pikiri.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Pikiri.Users

email = Application.fetch_env!(:pikiri, :admin_email)

{ :ok, user } = Users.create_user(%{email: email, role: "admin"})

# Remove this when login page is setup
{:ok, _magic_token, _claims} = Pikiri.Guardian.send_magic_link(user)
