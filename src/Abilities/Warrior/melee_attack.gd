class_name WarriorMeleeAttack extends Ability

@export var damage: int

func execute(hero: BaseHero, target = null):
	# TODO: Implement warrior melee attack
	print("Execute: WarriorMeleeAttack on ", target, " by ", hero.unit_name)
	pass
