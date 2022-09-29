extends CanvasLayer

# NODES
@onready var menu = $Menu
@onready var board: Board = $Board

# VARIABLES



# FUNCTIONS
func _ready():
	pass

func _on_client_pressed():
	menu.hide()
	start_client()

func start_client():
	var address = "localhost"
	var port = 1234
	print_debug("Connecting to %s:%d." % [address, port])
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", 1234)
	multiplayer.multiplayer_peer = peer
	multiplayer.connect("connected_to_server", _connected_to_server)


func _on_server_pressed():
	menu.hide()
	start_server()

func start_server():
	var port = 1234
	print_debug("Starting sever on port %d." % [port])
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, 32)
	multiplayer.multiplayer_peer = peer
	multiplayer.connect("peer_connected", _new_player)
	
	var deck := Deck.new("res://Lists/french.txt")
	var cards: Array = deck.deal_cards(board.get_board_size())
	prepare_game(cards)
	
	
@rpc(any_peer, call_local) func prepare_game(cards):
	board.set_cards(cards)

func _new_player(id):
	print_debug("Player %d connected." % id)
	var error = rpc_id(id, "prepare_game", board.get_cards())
	if error: print_debug("Error trying to sync cards: %", error)

func _connected_to_server():
	print_debug("Server reached.")


func _on_spymaster_button_toggled(button_pressed):
	board.set_show_type(button_pressed)
