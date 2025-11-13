class_name RangerRangedAttack extends Ability

@export var damage: int

func execute(hero: BaseHero, target = null):
	# TODO: Implement Ranger ranged attack
	print("Execute: RangerRangedAttack on ", target, " by ", hero.unit_name)
