extends Control

export var name = ""
export var val = ""

func _ready():
	redraw()

func redraw():
	get_node("Name").set_text(name + ":")
	get_node("Val").set_text(val)