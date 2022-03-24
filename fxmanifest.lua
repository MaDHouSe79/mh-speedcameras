fx_version 'cerulean'
game 'gta5'


description 'QB speedcameras'
version '1.0.0'

ui_page 'html/ui.html'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua', -- change en to your language
	"config.lua",
}
client_script { 
	"client/main.lua",
}
	
server_scripts {
	"server/main.lua",
	"config.lua",
}

files {
	'html/sound/*.ogg',
	'html/ui.html',
	'html/app.js',
}