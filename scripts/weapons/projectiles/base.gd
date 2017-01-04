
extends KinematicBody

export var speed = 7.0
export var damage = 3.0

var direction = Vector3()

func _ready():
	#check if projectile is inside a wall.
	var map_pos = MAP_MANAGER.get_map_pos(get_translation())
	if MAP_MANAGER.map[map_pos.x][map_pos.y].type != 1:
		queue_free()

func _fixed_process(delta):
	move(direction * speed * delta)
	
	if is_colliding():
		# allow physics to catch up.
		yield(get_tree(), "fixed_frame")
		on_collide()

func shoot(owner, pos, dir):
	direction = dir.normalized()
	set_translation(pos + direction)
	
	set_fixed_process(true)

func on_collide():
	print("test")
	pass
