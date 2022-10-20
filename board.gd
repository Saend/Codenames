extends Control
class_name Board

# NODES
@onready var container: GridContainer = $GridContainer


# SIGNALS
signal score_changed(red_score, red_count, blue_score, blue_count)

# VARIABLES
var starting_team
var is_spymaster: bool = false

var red_score: int
var red_count: int
var blue_score: int
var blue_count: int

@rpc(any_peer, call_local) func set_cards(cards):
	red_score = 0
	red_count = 0
	blue_score = 0
	blue_count = 0
	for i in range(cards.size()):
		if i < container.get_child_count():
			var card: Card = container.get_child(i)
			cards[i].show_type = is_spymaster
			card.set_data(cards[i])
			card.refresh()
			
			if not card.is_connected("played", on_card_played):
				card.connect("played", on_card_played)
			match card.type:
					"Red": 
						red_count = red_count + 1
						if card.is_played: red_score = red_score + 1
					"Blue": 
						blue_count = blue_count + 1
						if card.is_played: blue_score = blue_score + 1
	emit_signal("score_changed", red_score, red_count, blue_score, blue_count)


func on_card_played(type):
	match type:
		"Red": red_score = red_score + 1
		"Blue": blue_score = blue_score + 1
	emit_signal("score_changed", red_score, red_count, blue_score, blue_count)


func get_cards():
	var cards = []
	for card in container.get_children():
		cards.append({word = card.word, type = card.type, is_played = card.is_played})
		
	return cards
	

func get_board_size():
	return container.get_child_count()


func set_spymaster_mode(show_type):
	is_spymaster = show_type
	for card in container.get_children():
		card.show_type = show_type
		card.refresh()
