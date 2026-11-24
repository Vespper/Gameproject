class_name RoomOffer
extends RefCounted
## Un article posé sur un socle dans une salle sans combat : objet, type de tour ou soin.
## Prix 0 : gratuit (salle du trésor). Une fois pris, il ne revient pas.

enum Kind { ITEM, TOWER, HEAL }

var kind: Kind = Kind.ITEM
var item: ItemData
var tower: TowerData
var heal_amount: int = 0
var price: int = 0
var taken: bool = false


static func for_item(item_data: ItemData, cost: int) -> RoomOffer:
	var offer := RoomOffer.new()
	offer.kind = Kind.ITEM
	offer.item = item_data
	offer.price = cost
	return offer


static func for_tower(tower_data: TowerData, cost: int) -> RoomOffer:
	var offer := RoomOffer.new()
	offer.kind = Kind.TOWER
	offer.tower = tower_data
	offer.price = cost
	return offer


static func for_heal(amount: int, cost: int) -> RoomOffer:
	var offer := RoomOffer.new()
	offer.kind = Kind.HEAL
	offer.heal_amount = amount
	offer.price = cost
	return offer


func title() -> String:
	match kind:
		Kind.ITEM:
			return item.display_name
		Kind.TOWER:
			return "Tour " + tower.display_name
		_:
			return "Soin"


func description() -> String:
	match kind:
		Kind.ITEM:
			return item.description
		Kind.TOWER:
			return "Nouveau type de tour"
		_:
			return "+%d PV" % heal_amount


func color() -> Color:
	match kind:
		Kind.ITEM:
			return item.color
		Kind.TOWER:
			return tower.color
		_:
			return Color(0.9, 0.3, 0.35)
