class_name DamageCalculator extends RefCounted

const MIN_DAMAGE = 0

static func calculate_damage(base_damage: int, attacker: BaseHero, target: BaseUnit) -> int:
  print("Calculating damage: ", base_damage, " from ", attacker.unit_name, " to ", target.unit_name)
  var outgoing_damage = _calculate_outgoing_damage(base_damage, attacker)
  print("Outgoing damage: ", outgoing_damage)
  var incoming_damage = _calculate_incoming_damage(outgoing_damage, target)
  print("Incoming damage: ", incoming_damage)
  return incoming_damage


static func _calculate_outgoing_damage(base_damage: int, attacker: BaseHero) -> int:
  var multiplier = attacker.get_damage_multiplier()
  return roundi(base_damage * multiplier)


static func _calculate_incoming_damage(outgoing_damage: int, target: BaseUnit) -> int:
  var damage_multiplier = target.get_damage_received_multiplier()
  var damage_after_multiplier = outgoing_damage * damage_multiplier

  # TODO: Add flat damage reduction
	
  return max(MIN_DAMAGE, roundi(damage_after_multiplier))
