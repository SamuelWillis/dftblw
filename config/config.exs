import Config

config :dftblw, ecto_repos: [DFTBLW.Repo]

config :logger, level: :info

import_config "#{config_env()}.exs"
