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

email = Application.fetch_env!(:pikiri, :admin_email)

Pikiri.Repo.insert!(%Pikiri.Users.User{
    email: email
})
