{:ok, _} =
  App.Accounts.register_user(%{
    email: "test@example.com",
    password: "passpassword"
  })

{:ok, _} =
  App.Accounts.register_user(%{
    email: "dev@example.com",
    password: "passpassword"
  })

{:ok, _} =
  App.Accounts.register_user(%{
    email: "admin@example.com",
    password: "passpassword"
  })

{:ok, _} =
  App.Accounts.register_user(%{
    email: "alice@example.com",
    password: "passpassword"
  })
