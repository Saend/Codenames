extends Control
class_name ConnectionPopup

# SIGNALS
signal cancel


# NODES
@onready var label: Label = find_child("Label")


# VARIABLES
var text: String:
	set(new_text):
		label.text = new_text


# FUNCTIONS
func _on_cancel_button_pressed():
	emit_signal("cancel")
