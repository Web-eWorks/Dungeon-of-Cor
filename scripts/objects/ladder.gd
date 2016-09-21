
extends "pickups/pickup_base.gd"

func OnPickup( player ):
	DUNGEON_MANAGER.next_level()
	return true
