class_name DamageAbility extends Ability

@export var base_damage: int

func execute(hero: BaseHero, target: BaseUnit = null):
	var damage = DamageCalculator.calculate_damage(base_damage, hero, target)
	print("Damage: ", damage)
	target.take_damage(damage)