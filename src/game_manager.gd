extends Node2D

const HeroResource = preload("res://src/hero.gd")

func get_available_heroes() -> Array[Hero]:
	# TODO make this not hardcoded.
	var warrior_hero = HeroResource.new()
	warrior_hero.id = 1
	warrior_hero.name = "Warrior"
	warrior_hero.sprite = preload("res://Images/Heroes/Warrior/Warrior-portrait-removebg-preview.png")
	warrior_hero.health = 100
	warrior_hero.attack = 10
	warrior_hero.allowed_tiles = [Constants.TILE_TYPES.ROAD, Constants.TILE_TYPES.FOREST]
	
	var ranger_hero = HeroResource.new()
	ranger_hero.id = 2
	ranger_hero.name = "Ranger"
	ranger_hero.sprite = preload("res://Images/Heroes/Ranger/Ranger_portrait_removed_bg.png")
	ranger_hero.health = 80
	ranger_hero.attack = 13
	ranger_hero.allowed_tiles = [Constants.TILE_TYPES.FOREST]
	
	return [warrior_hero, ranger_hero]

func finish_setup():
	print("Finished setup, init round 1")
