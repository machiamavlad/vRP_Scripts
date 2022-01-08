----------------------------------------------------------------------
--      ||  ______          _                  _____  _____   ||	--
--      || |  ____|        | |                |  __ \|  __ \  ||	--
--      || | |__ __ _ _ __ | |_ __ _ ___ _   _| |__) | |__) | ||	--
--      || |  __/ _` | '_ \| __/ _` / __| | | |  _  /|  ___/  ||	--
--      || | | | (_| | | | | || (_| \__ \ |_| | | \ \| |      ||	--
--      || |_|  \__,_|_| |_|\__\__,_|___/\__, |_|  \_\_|      ||	--
--      ||                                __/ |               ||	--
--      ||                               |___/                ||	--
----------------------------------------------------------------------
--| Nu mai furati baieti si puneti osu la munca daca vreti cascaval |--
--|        Aveti cascada-n stomac futevas in gura de fomisti        |--
--|            © 2021 machiamavlad,  All rights reserved            |--
--| FANTASY ROMANIA NUMARU' 1 BAIETII MEI, NU ITI MERGE CU NOI MANZ |--
-----------------------------------------------------------------------

fx_version 'adamant'
game 'gta5'

author 'machiamavlad'

server_scripts {
	'@vrp/lib/utils.lua',
	'utils.lua',
	'server/*.lua'
}

client_scripts {
	'@vrp/client/Proxy.lua',
	'@vrp/client/Tunnel.lua',
	'client/*.lua'
}
files {
    'shellprops.ytyp',
    'shellpropsv2.ytyp'
}

data_file 'DLC_ITYP_REQUEST' 'shellprops.ytyp'
data_file 'DLC_ITYP_REQUEST' 'shellpropsv2.ytyp'