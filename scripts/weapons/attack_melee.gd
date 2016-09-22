
extends Node

export var Enabled = true
export var AnimationName = "attack"

export var CooldownTime = 0.7
export var MoveSpeedMul = 0.5

export var BaseDamage = 1.0
export var DamageMultiplier = 1.0
export var DamageOffset = 0.0

var AttackDamage setget , _getdmg

func _getdmg():
	return (BaseDamage+DamageOffset) * DamageMultiplier

func do_attack():
	var enemies = get_parent().HitBox.get_overlapping_bodies()
	for e in enemies:
		if e.is_queued_for_deletion():
			continue
		var is_grp = e.is_in_group("Enemy") or e.is_in_group("Damageable")
		if is_grp and e.has_method("take_damage"):
			yield(get_tree(), "idle_frame")
			e.take_damage(self.AttackDamage)

