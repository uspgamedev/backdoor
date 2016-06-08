
extends Node

func get_time_cost():
	return 100

func can_be_evoked(actor):
	return true

func get_options(actor):
	return []

func evoke(actor, options):
	print("Card evoked")
