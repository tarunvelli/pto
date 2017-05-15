# frozen_string_literal: true

require 'yaml'

yaml_data = YAML.safe_load(
  ERB.new(
    IO.read(
      File.join(Rails.root, 'config', 'application.yml')
    )
  ).result
)

APP_CONFIG = HashWithIndifferentAccess.new(yaml_data)

NO_OF_PTO = APP_CONFIG["no_of_pto"].to_i || 30
