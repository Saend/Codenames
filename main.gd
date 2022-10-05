extends CanvasLayer

# NODES
@onready var game_ui: Control = find_child("GameUI")
@onready var main_menu: Control = find_child("MainMenu")
@onready var board: Board = find_child("Board")
@onready var spymaster_list: ItemList = find_child("SpymasterList")
@onready var player_list: ItemList = find_child("PlayerList")
@onready var join_spymasters_button: Button = find_child("JoinSpymastersButton")

# VARIABLES
var player_name: String
var players: Dictionary = {}

# FUNCTIONS
func _ready():
	game_ui.hide()
	main_menu.show()


func _on_main_menu_exit():
	get_tree().quit()


func _on_main_menu_create_server(_name, port):
	print_debug("Starting sever on port %d." % [port])
	
	player_name = _name
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, 32)
	multiplayer.multiplayer_peer = peer
	multiplayer.connect("peer_connected", _peer_connected)
	multiplayer.connect("peer_disconnected", _peer_disconnected)
	
	var deck := Deck.new("res://Lists/french.txt")
	var cards: Array = deck.deal_cards(board.get_board_size())
	sync_state(cards, players)
	
	set_player_info({name = player_name})
	main_menu.hide()
	game_ui.show()


func _on_main_menu_join_server(_name, address, port: int):
	print_debug("Connecting to %s:%d." % [address, port])
	
	player_name = _name
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", port)
	multiplayer.multiplayer_peer = peer
	multiplayer.connect("connected_to_server", _connected_to_server)
	multiplayer.connect("server_disconnected", _server_disconnected, CONNECT_DEFERRED)


@rpc(any_peer, call_remote, reliable) func sync_state(cards, auth_players):
	board.set_cards(cards)
	for player in auth_players.values():
		if player.is_spymaster:
			player.index = spymaster_list.add_item(player.name)
		else:
			player.index = player_list.add_item(player.name)
		players[player.id] = player
			


func _peer_connected(id):
	print_debug("Player %d connected." % id)
	var error = rpc_id(id, "sync_state", board.get_cards(), players)
	if error: print_debug("Error trying to sync cards: %", error)



func _connected_to_server():
	print_debug("Server reached.")
	rpc_id(1, "set_player_info", {name = player_name})
	main_menu.hide()
	game_ui.show()


@rpc(any_peer, call_local, reliable) func set_player_info(info: Dictionary):
	var id: int = multiplayer.get_remote_sender_id()
	if id == 0: id = 1 #Server called this directly
	
	var full_info
	if players.has(id):
		full_info = players[id].duplicate()
	else :
		full_info = {id = id, name = "Player %d" % id, is_spymaster = false}
		
	full_info.merge(info, true)
	
	rpc("sync_player_info", full_info)


@rpc(any_peer, call_local, reliable) func sync_player_info(info: Dictionary):
	if players.has(info.id):
		if players[info.id].is_spymaster:
			spymaster_list.remove_item(players[info.id].index)
		else:
			player_list.remove_item(players[info.id].index)

	if info.is_spymaster:
		info.index = spymaster_list.add_item(info.name)
	else:
		info.index = player_list.add_item(info.name)

	players[info.id] = info


func _on_join_spymasters_button_pressed():
	rpc_id(1, "set_player_info", {is_spymaster = true})
	board.set_spymaster_mode(true)
	join_spymasters_button.hide()
	


func _peer_disconnected(id):
	rpc("sync_player_disconnect", id)


@rpc(any_peer, call_local) func sync_player_disconnect(id):
	if players.has(id):
		var index = players[id].index
		if players[id].is_spymaster:
			spymaster_list.remove_item(index)
		else:
			player_list.remove_item(index)
		players.erase(id)


func _server_disconnected():
	reset()


func _on_disconnect_button_pressed():
	# TODO: RPC disconnect intent
	reset()


func reset():
	multiplayer.multiplayer_peer = null
	get_tree().reload_current_scene()

