extends Control
class_name Board

@onready var container: GridContainer = $GridContainer
var starting_team


@rpc(any_peer, call_local) func set_cards(cards):
	for i in range(cards.size()):
		if i < container.get_child_count():
			var card: Card = container.get_child(i)
			card.word = cards[i].word
			card.type = cards[i].type
			card.played = cards[i].played
			card.show_type = false
			card.refresh()


func get_cards():
	var cards = []
	for card in container.get_children():
		cards.append({word = card.word, type = card.type, played = card.played})
		
	return cards
	

func get_board_size():
	return container.get_child_count()

func set_spymaster_mode(show_type):
	for card in container.get_children():
		card.show_type = show_type
		card.refresh()
