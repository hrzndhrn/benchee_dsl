Code.put_compiler_option(:ignore_module_conflict, true)

Mox.defmock(BencheeDsl.BencheeMock, for: BencheeDsl.Benchee)

Application.put_env(:benchee_dsl, :benchee, BencheeDsl.BencheeMock)
Application.put_env(:benchee_dsl, :benchee_run, false)

ExUnit.start(capture_log: true)
