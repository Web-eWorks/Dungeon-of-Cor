
extends "res:///scripts/objects/object_base.gd"

func set_clutter_type(table):
	#[{name, chance, billboard, roation}, ++]
	var clutter = GLOBAL.rand_choice(table)
	var tex = load("res://sprites/clutter/" + clutter["name"] + ".png")
	set_texture(tex)
	
	if clutter["billboard"]:
		set_offset(Vector2(tex.get_size().x * -0.5, 0))
	else:
		set_centered(true)
		set_axis(Vector3.AXIS_Y)
		billboard = false
	
	if clutter["rotation"]:
		set_rotation(Vector3(0, deg2rad(randf() * 360), 0))
