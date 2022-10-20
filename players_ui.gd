extends Control
class_name PlayersUI


# SIGNAL
signal join_spymasters


# NODES
@onready var spymaster_list: ItemList = find_child("SpymasterList")
@onready var player_list: ItemList = find_child("PlayerList")
@onready var join_spymasters_button: Button = find_child("JoinSpymastersButton")
@onready var red_score_label: Label = find_child("RedScore")
@onready var blue_score_label: Label = find_child("BlueScore")


# VARIABLES
var players: Dictionary = {}


# FUNCTIONS
func set_players(_players):
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


func get_players():
	return players


func _on_join_spymasters_button_pressed():
	emit_signal("join_spymasters")
	

func set_score(red_score: int, red_count: int, blue_score: int, blue_count: int):
	red_score_label.text = "%d/%d" % [red_score, red_count]
	blue_score_label.text = "%d/%d" % [blue_score, blue_count]
