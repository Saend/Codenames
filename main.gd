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
	
	for player in players.values():
		player.is_spymaster = false
	rpc("sync_players", players)


func _on_main_menu_join_server(_name, address, port: int):
	player_name = _name
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	multiplayer.multiplayer_peer = peer
	multiplayer.connect("connected_to_server", _connected_to_server)
	multiplayer.connect("server_disconnected", _server_disconnected, CONNECT_DEFERRED)


@rpc(any_peer, call_local, reliable) func sync_cards(cards):
	board.set_cards(cards)


@rpc(any_peer, call_local, reliable) func sync_players(_players):
	players = _players
	
	spymaster_list.clear()
	player_list.clear()
	
	for player in players.values():
		var list: ItemList = spymaster_list if player.is_spymaster else player_list
		var index = list.add_item(player.name)
		list.set_item_selectable(index, false)
	
	var id = multiplayer.get_unique_id()
	if players.has(id):
		join_spymasters_button.visible = not players.get(id).is_spymaster


func _peer_connected(id):
	rpc_id(id, "sync_cards", board.get_cards())
	rpc_id(id, "sync_players", players)


func _connected_to_server():
	rpc_id(1, "set_player_info", {name = player_name})
	main_menu.hide()
	game_ui.show()


@rpc(any_peer, call_local, reliable) func set_player_info(info: Dictionary):
	var id: int = multiplayer.get_remote_sender_id()
	if id == 0: id = 1 #Server called this directly
	
	if not players.has(id):
		players[id] = {id = id, name = "Player %d" % id, is_spymaster = false}
		
	players[id].merge(info, true)
	rpc("sync_players", players)


func _on_join_spymasters_button_pressed():
	rpc_id(1, "set_player_info", {is_spymaster = true})
	board.set_spymaster_mode(true)
	join_spymasters_button.hide()


func _peer_disconnected(id):
	players.erase(id)
	rpc("sync_players", players)


func _server_disconnected():
	reset()


func _on_disconnect_button_pressed():
	# TODO: RPC disconnect intent
	reset()


func reset():
	multiplayer.multiplayer_peer = null
	get_tree().reload_current_scene()


func _on_new_game_button_pressed():
	new_game()
