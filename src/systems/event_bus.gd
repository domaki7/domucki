extends Node

signal entity_died(entity: Node3D)
signal entity_damaged(entity: Node3D, amount: float)
signal item_picked_up(item: Resource, picker: Node3D)
signal interaction_started(interactor: Node3D, target: Node3D)
signal interaction_ended(interactor: Node3D, target: Node3D)
signal dialog_started(npc: Node3D)
signal dialog_ended(npc: Node3D)
