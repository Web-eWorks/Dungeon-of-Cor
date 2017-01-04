
extends "res:///scripts/weapons/projectiles/base.gd"

export var size_per_second = .6
export var initial_size = 1

var is_exploding = false
var smoke_scene = preload("res://scenes/effects/smoke.scn")

onready var Overlap = get_node("Area/Overlap")
onready var overlap_shape = SphereShape.new()

func _ready():
	overlap_shape.set_radius(initial_size)
	Overlap.set_shape(overlap_shape)
	#check if fireball is inside a wall.
	var map_pos = MAP_MANAGER.get_map_pos(get_translation())
	if MAP_MANAGER.map[map_pos.x][map_pos.y].type != 1:
		queue_free()

func _fixed_process(delta):
	var r = overlap_shape.get_radius()
	r = r + (r * size_per_second) * delta
	overlap_shape.set_radius(r)
	r = ((r - initial_size) / 2) + initial_size
	get_node("Sprite3D").set_pixel_size(r * 0.032)

func shoot(owner, pos, dir):
	dir.y = 0
	.shoot(owner, pos, dir)

func on_collide():
	is_exploding = true
	var bodies = get_node("Area").get_overlapping_bodies()
	for b in bodies:
		if b.has_method("take_damage") and !b.is_queued_for_deletion():
			b.take_damage(damage)
	
	var se = smoke_scene.instance()
	var pos = get_translation()
	se.set_translation(Vector3(pos.x, 0, pos.z))
	get_parent().add_child(se)
	queue_free()

func take_damage(amnt):
	if not is_exploding:
		on_collide()
