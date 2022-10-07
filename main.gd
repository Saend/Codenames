extends CanvasLayer

# NODES
@onready var game_ui: Control = find_child("GameUI")
@onready var main_menu: Control = find_child("MainMenu")
@onready var popup:  = find_child("ConnectionPopup")
@onready var board: Board = find_child("Board")
@onready var players_ui: PlayersUI = find_child("PlayersUI")

# VARIABLES
var player_name: String

# FUNCTIONS
func _ready():
	game_ui.hide()
	main_menu.show()
	popup.hide()


func _on_main_menu_exit():
	get_tree().quit()


func _on_main_menu_create_server(_name, port):
	player_name = _name
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, 32)
	multiplayer.multiplayer_peer = peer
	multiplayer.connect("peer_connected", _peer_connected)
	multiplayer.connect("peer_disconnected", _peer_disconnected)
	
	set_player_info({name = player_name})
	new_game()
	
	main_menu.hide()
	game_ui.show()


func new_game():
	var deck := Deck.new("res://Lists/french.txt")
	var cards: Array = deck.deal_cards(board.get_board_size())
	rpc("sync_cards", cards)
	
	var players = players_ui.get_players()
	for player in players.values():
		player.is_spymaster = false
	rpc("sync_players", players)


func _on_main_menu_join_server(_name, address, port: int):
	player_name = _name
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	multiplayer.multiplayer_peer = peer
	if not multiplayer.is_connected("connected_to_server", _connected_to_server):
		multiplayer.connect("connected_to_server", _connected_to_server)
	if not multiplayer.is_connected("server_disconnected", _server_disconnected):
		multiplayer.connect("server_disconnected", _server_disconnected, CONNECT_DEFERRED)
	
	popup.text = "Connecting to %s" % address
	popup.show()
	


@rpc(any_peer, call_local, reliable) func sync_cards(cards):
	board.set_cards(cards)


@rpc(any_peer, call_local, reliable) func sync_players(players):
	players_ui.set_players(players)


func _peer_connected(id):
	rpc_id(id, "sync_cards", board.get_cards())
	rpc_id(id, "sync_players", players_ui.get_players())


func _connected_to_server():
	rpc_id(1, "set_player_info", {name = player_name})
	main_menu.hide()
	game_ui.show()
	popup.hide()


@rpc(any_peer, call_local, reliable) func set_player_info(info: Dictionary):
	var id: int = multiplayer.get_remote_sender_id()
	if id == 0: id = 1 #Server called this directly
	
	var players = players_ui.get_players()
	if not players.has(id):
		players[id] = {id = id, name = "Player %d" % id, is_spymaster = false}
		
	players[id].merge(info, true)
	rpc("sync_players", players)


func _on_players_ui_join_spymasters():
	rpc_id(1, "set_player_info", {is_spymaster = true})
	board.set_spymaster_mode(true)


func _peer_disconnected(id):
	var players = players_ui.get_players()
	players.erase(id)
	rpc("sync_players", players)


func _server_disconnected():
	main_menu.press_join()


func _on_popup_cancel():
	reset()


func _on_disconnect_button_pressed():
	# TODO: RPC disconnect intent
	reset()


func reset():
	multiplayer.multiplayer_peer = null
	get_tree().reload_current_scene()


func _on_new_game_button_pressed():
	new_game()




