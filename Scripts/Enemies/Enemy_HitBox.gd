# Author: Yalmaz
# Description: HitBox for enemies. Holds attack info
class_name Enemy_Hitbox
extends Area2D

# damage parameters of hitbox
export(float) var damage = 0.0

# effect parameters of hitbox
export(String) var status = ""
export(float) var status_duration = 0.0
