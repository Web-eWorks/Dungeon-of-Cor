
extends "attack_base.gd"

export(String, FILE) var Projectile = "res://scenes/effects/fireball.scn"
export var ProjectileSpeed = 8
export var ProjectileDamage = 3

func do_attack():
	var player = get_owner().parent
	var proj = load(Projectile).instance()
	proj.speed = ProjectileSpeed
	proj.damage = ProjectileDamage
	proj.shoot(player.get_translation() + Vector3(0, 1, 0), -player.get_transform().basis.z)
	player.get_parent().add_child(proj)