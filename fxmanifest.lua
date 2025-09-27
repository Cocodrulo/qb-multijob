fx_version "cerulean"
game "gta5"

author "Cocodrulo - QBCore"
version "0.0.1"
description "A multi-job script for QBCore framework"

shared_scripts {
	'@qb-core/shared/locale.lua',
    "Config.lua",
	"locales/*.lua",
}

client_scripts {
    "client/main.lua",
    "client/exports.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua"
}