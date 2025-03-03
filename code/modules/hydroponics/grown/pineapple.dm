// Pineapple!
/obj/item/seeds/pineapple
	name = "Пачка семян ананаса"
	desc = "Вырастут в сладенький плод!"
	icon_state = "seed-pineapple"
	species = "pineapple"
	plantname = "Pineapple Plant"
	product = /obj/item/food/grown/pineapple
	lifespan = 40
	endurance = 30
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/juicing)
	mutatelist = list(/obj/item/seeds/apple)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.02, /datum/reagent/consumable/nutriment = 0.2, /datum/reagent/water = 0.04)
	graft_gene = /datum/plant_gene/trait/juicing

/obj/item/food/grown/pineapple
	seed = /obj/item/seeds/pineapple
	name = "Ананас"
	desc = "Смешной по форме фрукт."
	icon_state = "pineapple"
	force = 4
	throwforce = 8
	hitsound = 'sound/weapons/sword_kill_slash_01.ogg'
	attack_verb_continuous = list("жалит", "ананасит")
	attack_verb_simple = list("жалит", "ананасит")
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	foodtypes = FRUIT | PINEAPPLE
	juice_results = list(/datum/reagent/consumable/pineapplejuice = 0)
	tastes = list("ананас" = 1)
	wine_power = 40


/obj/item/food/grown/pineapple/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/pineappleslice, 3, 15)
