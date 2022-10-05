extends RefCounted
class_name Deck

var word_list: Array[String] = []

func _init(path: = ""):
	if not path.is_empty(): read_word_list(path)

func read_word_list(path: String):
	var file := FileAccess.open(path, FileAccess.READ)
	var error := file.get_open_error()
	if error:
		print_debug("Could not open word list file: %", error)
		return
	
	while file.get_position() < file.get_length():
		word_list.append(file.get_line())
	file = null


func deal_cards(total: int = 25, assassins: int = 1, blues: int = 9, reds: int = 8):
	assert(total >= assassins + blues + reds)
	print_debug("Generating cards of %d word_list." % total)
	
	var words: = []
	while words.size() < total:
		var word = word_list[randi() % word_list.size()]
		if not words.has(word):
			words.append(word)
			
	var cards = words.map(func(word): return {word = word, type = "Innocent", played = false})
	for i in range(assassins): cards[i].type = "Assassin"
	for i in range(assassins, assassins+blues-1): cards[i].type = "Blue"
	for i in range(assassins+blues, assassins+blues+reds-1): cards[i].type = "Red"
	
	cards.shuffle()
	return cards
