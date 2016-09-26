
extends Control

var item = null

export(Texture) var icon = preload("res://sprites/weapons/sword.png")

onready var button = get_node("Button")
onready var tex = get_node("Button/Texture")

func _ready():
	redraw()

func redraw():
	tex.set_texture(icon)
