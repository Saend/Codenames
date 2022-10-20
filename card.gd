extends TextureButton
class_name Card

# CONSTANTS
const assassin_back_texture: Texture2D = preload("res://Images/assassin_back.svg")
const assassin_front_texture: Texture2D = preload("res://Images/assassin_front.svg")
const blank_back_texture: Texture2D = preload("res://Images/blank_back.svg")
const blank_front_texture: Texture2D = preload("res://Images/blank_front.svg")
const blue_back_texture: Texture2D = preload("res://Images/blue_back.svg")
const blue_front_texture: Texture2D = preload("res://Images/blue_front.svg")
const innocent_back_texture: Texture2D = preload("res://Images/innocent_back.svg")
const innocent_front_texture: Texture2D = preload("res://Images/innocent_front.svg")
const red_back_texture: Texture2D = preload("res://Images/red_back.svg")
const red_front_texture: Texture2D = preload("res://Images/red_front.svg")

# NODES
@onready var label: Label = $Label

# VARIABLES
var word: String
var type: String
var played: bool = false
var show_type: bool = false

var front: Texture2D
var back: Texture2D


# FUNCTIONS
func refresh():
	match type:
		"Blue": 
			texture_disabled = blue_back_texture
			front = blue_front_texture
		"Red": 
			texture_disabled = red_back_texture
			front = red_front_texture
		"Assassin": 
			texture_disabled = assassin_back_texture
			front = assassin_front_texture
		"Innocent": 
			texture_disabled = innocent_back_texture
			front = innocent_front_texture
		_: 
			texture_disabled = blank_back_texture
			front = blank_front_texture
	
	label.text = word
	label.visible = not played
	texture_normal = front if show_type else blank_front_texture
	disabled = played


func _on_card_button_up():
	if multiplayer.has_multiplayer_peer():
		rpc("play_card")


@rpc(any_peer, call_local) func play_card():
	$AnimationPlayer.play("Click")
	played = true
	refresh()


func _on_card_focus_entered():
	pass # Replace with function body.
