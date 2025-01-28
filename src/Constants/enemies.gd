class_name Enemies

enum EnemyNames {
  ORANGE_DUDE_ENEMY
}

const orange_dude_enemy_scene = preload("res://scenes/Units/Enemies/orange_dude_enemy.tscn")

const ENEMY_SCENES = {
  EnemyNames.ORANGE_DUDE_ENEMY: orange_dude_enemy_scene
}
