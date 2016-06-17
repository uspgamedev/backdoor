
extends "res://model/card_ref.gd"

class SlotItem:
	const WEAPON = 0
	const ARMORY = 1
	const ACCESSORY  = 2

export(int, "WEAPON", "ARMORY", "ACCESSORY") var slot = 0

func get_slot():
	return slot

func evoke(actor, options):
	if slot == SlotItem.WEAPON:
		print("equip weapon ", self.get_name())
		actor.weapon = self
	elif slot == SlotItem.ARMORY:
		print("equip armory ", self.get_name())
		actor.armory = self
	elif slot == SlotItem.ACCESSORY:
		print("equip accessory ", self.get_name())
		actor.accessory = self
	show_equips(actor)

func show_equips(actor):
	var weapon = "none"
	if actor.weapon != null:
		weapon = actor.weapon.get_name()
	var armory
	if actor.armory != null:
		armory = actor.armory.get_name()
	var accessory
	if actor.accessory != null:
		accessory = actor.accessory.get_name()
	
	print("equipments")
	print("weapon=", weapon)
	print("armory=", armory)
	print("accessory=", accessory)