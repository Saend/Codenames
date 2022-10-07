extends Control

# SIGNAL
signal exit
signal create_server(player_name:String, port: int)
signal join_server(player_name:String, address: String, port: int)

# NODES
@onready var player_name: LineEdit = find_child("PlayerName")
@onready var server_address: LineEdit = find_child("ServerAddress")
@onready var port_number: LineEdit = find_child("PortNumber")
@onready var join_button: Button = find_child("JoinButton")


# VARIABLES
const cfg_path := "user.cfg"
var cfg := ConfigFile.new()


func cfg_get_value_or_empty_string(section: String, key: String):
	if cfg.has_section_key(section, key):
		return str(cfg.get_value(section, key))
	else: return ""


func _ready():
	if FileAccess.file_exists(cfg_path):
		cfg.load(cfg_path)
		player_name.text = cfg_get_value_or_empty_string("General", "player_name")
		server_address.text = cfg_get_value_or_empty_string("General", "server_address")
		port_number.text = cfg_get_value_or_empty_string("General", "port_number")


func _on_quit_button_pressed():
	emit_signal("exit")


func _on_join_button_pressed():
	var player = player_name.text
	if player.is_empty():
		print_debug("Cannot join server: empty user name.")
	
	var uri = server_address.text.split(':')
	var address = uri[0]
	if address.is_empty(): 
		print_debug("Cannot join server: bad address.")
		return
	
	var port : int = 1234
	if uri.size() == 2:
		port = uri[1].to_int()
	elif uri.size() > 1:
		print_debug("Cannot join server: bad address.")
		return
	
	cfg.set_value("General", "player_name", player)
	cfg.set_value("General", "server_address", server_address.text)
	cfg.save(cfg_path)
	
	emit_signal("join_server", player, address, port)


func _on_create_button_pressed():
	var player = player_name.text
	if player.is_empty():
		print_debug("Cannot join server: empty user name.")
		
	var port = port_number.text.to_int()
	if port <= 0:
		print_debug("Cannot create server: bad port.")

	cfg.set_value("General", "player_name", player)
	cfg.set_value("General", "port_number", port)
	cfg.save(cfg_path)
	
	emit_signal("create_server", player, port)
		

func press_join():
	join_button.emit_signal("pressed")
