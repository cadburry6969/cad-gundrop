fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author 'Cadburry (Bytecode Studios)'
description 'Item Air Drop System'

shared_scripts {
    "@ox_lib/init.lua",
    "config.lua",
}

client_scripts {
    "bridge/client.lua",
    "module/client.lua"
}

server_scripts {
    "bridge/server.lua",
    "module/server.lua"
}