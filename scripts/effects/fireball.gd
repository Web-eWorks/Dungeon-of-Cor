
extends KinematicBody

export var speed = 7
export var damage = 3
export var size_per_second = 1
export var initial_size = 1
var direction = Vector3()

var is_active = true
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
	move(direction * speed * delta)
	overlap_shape.set_radius(overlap_shape.get_radius() + size_per_second * delta)
	
	if is_colliding():
		explode()

func shoot(pos, dir):
	dir.y = 0
	direction = dir.normalized()
	set_translation(pos + direction * 1.2)
	
	set_fixed_process(true)

func explode():
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
		explode()
