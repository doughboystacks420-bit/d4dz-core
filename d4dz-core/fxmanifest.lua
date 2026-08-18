fx_version 'cerulean'
games { 'gta5' }

author 'd4dz Development'
description 'The decentralized master framework engine for the d4dz ecosystem.'
version '1.0.0'

provide 'd4dz-core'

-- ADD THIS EXPORT LINE HERE:
exports {
    'GetLocaleClass'
}

dependencies {
    'oxmysql'
}
-- ... leave the rest of your manifest exactly as it is


-- Streamlined shared scripts array
shared_scripts {
    'shared/locale.lua',
    'shared/main.lua'
}

server_scripts {
    'server/player.lua',
    'server/debug.lua',
    'server/functions.lua',
    'server/events.lua',
    'server/commands.lua',
    'server/exports.lua'
}

client_scripts {
    'client/drawtext.lua',
    'client/events.lua',
    'client/functions.lua',
    'client/loops.lua'
}

ui_page 'html/index.html'

files {
    'shared/locale.lua', -- FIX: Exposes this file so @d4dz-core paths work in other scripts
    'html/index.html',
    'html/css/style.css',
    'html/css/drawtext.css',
    'html/js/app.js',
    'html/js/drawtext.js'
}
