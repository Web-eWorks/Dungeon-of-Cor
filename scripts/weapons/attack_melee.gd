
extends "attack_base.gd"

export var BaseDamage = 1.0

func do_attack():
	var enemies = get_parent().HitBox.get_overlapping_bodies()
	for e in enemies:
		if e.is_queued_for_deletion():
			continue
		var is_grp = e.is_in_group("Enemy") or e.is_in_group("Damageable")
		if is_grp and e.has_method("take_damage"):
			yield(get_tree(), "idle_frame")
			e.take_damage(BaseDamage)

