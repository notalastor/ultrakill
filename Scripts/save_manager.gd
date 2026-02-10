extends Node

# Audio bus indices - adjust these if your buses are in different positions
# (Master bus is 0, then Music, then SFX, etc.)
const MUSIC_BUS_INDEX = 1
const SFX_BUS_INDEX = 2

# Audio volume properties with setter callbacks
var music_volume: float = 1.0:
	set(value):
		AudioServer.set_bus_volume_db(MUSIC_BUS_INDEX, linear_to_db(value))
		music_volume = value
	get:
		return music_volume

var sfx_volume: float = 1.0:
	set(value):
		AudioServer.set_bus_volume_db(SFX_BUS_INDEX, linear_to_db(value))
		sfx_volume = value
	get:
		return sfx_volume

# Configuration file path
const CFG_PATH = "user://config.cfg"


func _ready():
	load_config_file()


func load_config_file() -> void:
	var config: ConfigFile = ConfigFile.new()
	var error: int = config.load(CFG_PATH)
	
	if error != OK:
		if error != ERR_FILE_NOT_FOUND:
			printerr("Error loading config file. Error: ", error_string(error))
		# Create default config if file doesn't exist
		save_config_file()
		return
	
	music_volume = config.get_value("audio_settings", "music_volume", 1.0)
	sfx_volume = config.get_value("audio_settings", "sfx_volume", 1.0)


func save_config_file() -> void:
	var config: ConfigFile = ConfigFile.new()
	
	config.set_value("audio_settings", "music_volume", music_volume)
	config.set_value("audio_settings", "sfx_volume", sfx_volume)
	
	var error: int = config.save(CFG_PATH)
	if error != OK:
		printerr("Error saving config file, error: ", error_string(error))
