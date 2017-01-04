
extends "res:///scripts/objects/object_base.gd"

func _ready():
	connect("body_enter", self, "_onBodyEnter")

func _onBodyEnter(body):
	if body.is_in_group("Player") and not body.is_dead:
		if has_method("OnPickup") and OnPickup(body):
			queue_free()
