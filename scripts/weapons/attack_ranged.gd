
extends Node

export var Enabled = true

export var AnimationName = "shoot"
export var CooldownTime = 1.0
export(String, FILE) var Projectile = "res://scenes/effects/fireball.scn"
export var MoveSpeedMul = 0.5

func do_attack():
	var player = get_owner().parent
	var proj = load(Projectile).instance()
	proj.shoot(player.get_translation() + Vector3(0, 1, 0), -player.get_transform().basis.z)
	player.get_parent().add_child(proj)