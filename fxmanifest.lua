fx_version 'cerulean'
game 'gta5'
description 'Police vehicle tracker'
version '1.0'

shared_script 'config.lua'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page "html/index.html"

files {
    'html/index.html',
    'html/police.ttf',
    'html/style.css',
    'html/handler.js'
}

lua54 'yes'