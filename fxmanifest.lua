fx_version 'cerulean'
game 'gta5'
lua54 'yes' -- Enable Lua 5.4 features if desired, ensure your server supports it. 
author 'r1nzox-lab'
description 'Shotspotter Alert System'
version '1.0.0'

shared_scripts {
    'config.lua'
 }
 
client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}


dependencies {
   'ps-dispatch' , 
   'MugShotBase64'
}
