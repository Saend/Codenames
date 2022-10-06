extends TextureButton
class_name Card

# EXPORTS
@export var assassin_back_texture: Texture2D
@export var assassin_front_texture: Texture2D
@export var blank_back_texture: Texture2D
@export var blank_front_texture: Texture2D
@export var blue_back_texture: Texture2D
@export var blue_front_texture: Texture2D
@export var innocent_back_texture: Texture2D
@export var innocent_front_texture: Texture2D
@export var red_back_texture: Texture2D
@export var red_front_texture: Texture2D

# NODES
@onready var label: Label = $Label

# VARIABLES
var word: String = "Codename"
var type: String = ""
var played: bool = false

var show_type: bool

# FUNCTIONS
func refresh():
	label.text = word
	if played:
		label.visible = false
		match type:
			"Blue": texture_normal = blue_back_texture
			"Red": texture_normal = red_back_texture
			"Assassin": texture_normal = assassin_back_texture
			"Innocent": texture_normal = innocent_back_texture
			_: texture_normal = blank_back_texture
	else:
		label.visible = true
		if show_type:
			match type:
				"Blue": texture_normal = blue_front_texture
				"Red": texture_normal = red_front_texture
				"Assassin": texture_normal = assassin_front_texture
				"Innocent": texture_normal = innocent_front_texture
				_: texture_normal = blank_front_texture
		else: texture_normal = blank_front_texture


func _on_card_button_up():
	rpc("play_card")


@rpc(any_peer, call_local) func play_card():
	played = true
	refresh()


func _on_card_focus_entered():
	pass # Replace with function body.
