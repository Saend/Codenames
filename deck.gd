extends RefCounted
class_name Deck

var word_list: Array[String] = []

func _init(path: = ""):
	if not path.is_empty(): read_word_list(path)

func read_word_list(path: String):
	var file := FileAccess.open(path, FileAccess.READ)
	var error := FileAccess.get_open_error()
	if error:
		print_debug("Could not open word list file: %s" % error_string(error))
		return
	
	while file.get_position() < file.get_length():
		word_list.append(file.get_line())
	file = null


func deal_cards(total: int, blues: int, reds: int, assassins: int = 1):
	assert(total >= assassins + blues + reds)
	print_debug("Generating cards of %d word_list." % total)
	
	var words: = []
	while words.size() < total:
		var word = word_list[randi() % word_list.size()]
		if not words.has(word):
			words.append(word)
			
	var cards = words.map(func(word): return {word = word, type = "Innocent", is_played = false})
	for i in range(assassins): cards[i].type = "Assassin"
	for i in range(assassins, assassins+blues): cards[i].type = "Blue"
	for i in range(assassins+blues, assassins+blues+reds): cards[i].type = "Red"
	
	cards.shuffle()
	return cards
