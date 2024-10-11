require "canister"
require "byebug"

Services = Canister.new
S = Services

S.register(:push_locations) do
  ENV.fetch("PUSH_LOCATIONS", "").split("||")
end

S.register(:push_locations?) do
  !S.push_locations.empty?
end

S.register(:project_root) do
  File.absolute_path(File.join(__dir__, ".."))
end
