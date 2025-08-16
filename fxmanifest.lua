fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'qbx_coords_helper'
author 'odnavpt + ChatGPT'
description 'Helper de coordenadas: /coords, /olhar, HUD e integração opcional com ox_target.'
version '1.0.0'

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua'
}

client_scripts {
  'client.lua'
}

dependencies {
  'ox_lib'
  -- 'ox_target' (opcional, apenas se quiseres o menu de foco)
}
