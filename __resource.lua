
resource_manifest_version "77731fab-63ca-442c-a67b-abc70f28dfa5"

dependency "vrp"

client_script {
    "config.lua",
    "client.lua",
}

server_script {
    "@vrp/lib/utils.lua",
    "config.lua",
    "server.lua",
}