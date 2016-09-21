extends Node

export var CooldownTime = 0.7
export var HitboxSize = Vector3(.5, .5, .5)

export var MoveSpeedMul = 0.5

export var BaseDamage = 1.0
export var DamageMultiplier = 1.0
export var DamageExtra = 0.0

export var RangedAttack = false

var WeaponDamage setget ,_getWeaponDamage

func _getWeaponDamage():
	return (BaseDamage + DamageExtra) * DamageMultiplier