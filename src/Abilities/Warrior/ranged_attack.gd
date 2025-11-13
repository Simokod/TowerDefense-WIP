class_name WarriorRangedAttack extends Ability

@export var damage: int

func execute(hero: BaseHero, target = null):
	# TODO: Implement Warrior ranged attack
	print("Execute: WarriorRangedAttack on ", target, " by ", hero.unit_name)
	pass
