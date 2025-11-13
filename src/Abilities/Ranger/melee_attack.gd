class_name RangerMeleeAttack extends Ability

@export var damage: int

func execute(hero: BaseHero, target: BaseUnit = null):
	# TODO: Implement Ranger melee attack
	print("Execute: RangerMeleeAttack on ", target, " by ", hero.unit_name)
