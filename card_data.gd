extends Resource
class_name CardData

enum CardType {INNOCENT, BLUE, RED, ASSASSIN}

var word: String
var type: CardType = CardType.INNOCENT

func _init(_word = ""):
	word = _word
