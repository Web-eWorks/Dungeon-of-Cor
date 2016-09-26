
extends "attack_base.gd"

export var scan_dist = 1.75

func _fixed_process(delta):
	var tr_1 = weapon.get_global_transform()
	var start = tr_1.origin
	var end = tr_1.xform(Vector3(0, 0, -scan_dist))
	
	var state = weapon.get_world().get_direct_space_state()
	var hit = state.intersect_ray(start, end, [weapon, weapon.parent])
	
	if not hit.empty():
		var pos = hit.position
		var collider = hit.collider
		#FIXME Works, for the most part.  Need to get the map pos of the
		# block we actually clicked on.
		var bpos = MAP_MANAGER.get_map_pos(pos + (pos-start).normalized())
		
		MAP_MANAGER.map[bpos.x][bpos.y].type = 1
		MAP_MANAGER.update_map_tile(bpos)
	
	set_fixed_process(false)

func do_attack():
	set_fixed_process(true)
