
extends "pickup_base.gd"

export var HealAmount = 3

func OnPickup( body ):
	if body.health < 10:
		body.heal(HealAmount)
		return true
