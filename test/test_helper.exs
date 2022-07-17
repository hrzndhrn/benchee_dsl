if function_exported?(Code, :put_compiler_option, 2),
  do: Code.put_compiler_option(:ignore_module_conflict, true)

Mox.defmock(BencheeDsl.BencheeMock, for: BencheeDsl.Benchee)
Application.put_env(:benchee_dsl, :benchee, BencheeDsl.BencheeMock)

benchee_run = if System.get_env("CI"), do: true, else: false
Application.put_env(:benchee_dsl, :benchee_run, benchee_run)

ExUnit.start(capture_log: true)
