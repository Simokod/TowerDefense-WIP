class_name DamageAbility extends Ability

const damageCalculator = preload("res://src/Combat/damage_calculator.gd")
@export var base_damage: int

func execute(hero: BaseHero, target: BaseUnit = null):
	var damage = damageCalculator.calculate_damage(base_damage, hero, target)
	print("Damage: ", damage)
	target.take_damage(damage)