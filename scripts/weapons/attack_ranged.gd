
extends "attack_base.gd"

export(String, FILE) var Projectile = "res://scenes/effects/fireball.scn"
export var ProjectileSpeed = 8
export var ProjectileDamage = 3

func do_attack():
	var player = get_owner().parent
	var proj = load(Projectile).instance()
	proj.speed = ProjectileSpeed
	proj.damage = ProjectileDamage
	var start = player.get_translation() + Vector3(0, 1, 0)
	var dir = -player.get_transform().basis.z
	proj.shoot(player, start + dir.normalized() * proj.initial_size, dir)
	player.get_parent().add_child(proj)