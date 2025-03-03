/* Kitchen tools
 * Contains:
 * Fork
 * Kitchen knives
 * Ritual Knife
 * Bloodletter
 * Butcher's cleaver
 * Combat Knife
 * Rolling Pins
 * Plastic Utensils
 */

/obj/item/kitchen
	icon = 'icons/obj/kitchen.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'

/obj/item/kitchen/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_APC_SHOCKING, INNATE_TRAIT)

/obj/item/kitchen/fork
	name = "вилка"
	desc = "Один удар четыре дырки."
	icon_state = "fork"
	force = 4
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron=80)
	flags_1 = CONDUCT_1
	attack_verb_continuous = list("attacks", "stabs", "pokes")
	attack_verb_simple = list("attack", "stab", "poke")
	hitsound = 'sound/weapons/stab1.ogg'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)
	sharpness = SHARP_POINTY
	var/datum/reagent/forkload //used to eat omelette
	custom_price = PAYCHECK_PRISONER

/obj/item/kitchen/fork/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/eyestab)

/obj/item/kitchen/fork/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] stabs <b>[src]</b> into [user.p_their()] chest! It looks like [user.p_theyre()] trying to take a bite out of [user.p_them()]self!"))
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE)
	return BRUTELOSS

/obj/item/kitchen/fork/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))
		return ..()

	if(forkload)
		if(M == user)
			M.visible_message(span_notice("[user] eats a delicious forkful of omelette!"))
			M.reagents.add_reagent(forkload.type, 1)
		else
			M.visible_message(span_notice("[user] feeds [M] a delicious forkful of omelette!"))
			M.reagents.add_reagent(forkload.type, 1)
		icon_state = "fork"
		forkload = null
	else
		return ..()

/obj/item/kitchen/fork/plastic
	name = "пластиковая вилка"
	desc = "Ностальгия возвращает тебя обратно к школьному столу."
	icon_state = "plastic_fork"
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	custom_materials = list(/datum/material/plastic=80)
	custom_price = PAYCHECK_PRISONER * 2
	var/break_chance = 25

/obj/item/kitchen/fork/plastic/afterattack(atom/target, mob/user)
	. = ..()
	if(prob(break_chance))
		user.visible_message(span_danger("[user]'s fork snaps into tiny pieces in their hand."))
		qdel(src)

/obj/item/kitchen/knife
	name = "кухонный нож"
	icon_state = "knife"
	inhand_icon_state = "knife"
	worn_icon_state = "knife"
	desc = "Универсальный поварской нож производства Космо Шэф Инк. Гарантированно останется острым на долгие годы."
	flags_1 = CONDUCT_1
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 10
	hitsound = 'sound/weapons/sword_kill_slash_01.ogg'
	throw_speed = 3
	throw_range = 6
	custom_materials = list(/datum/material/iron=12000)
	attack_verb_continuous = list("slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_EDGED
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	var/bayonet = FALSE //Can this be attached to a gun?
	wound_bonus = -5
	bare_wound_bonus = 10
	tool_behaviour = TOOL_KNIFE

/obj/item/kitchen/knife/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/eyestab)
	set_butchering()

///Adds the butchering component, used to override stats for special cases
/obj/item/kitchen/knife/proc/set_butchering()
	AddComponent(/datum/component/butchering, 80 - force, 100, force - 10) //bonus chance increases depending on force

/obj/item/kitchen/knife/suicide_act(mob/user)
	user.visible_message(pick(span_suicide("[user] is slitting [user.p_their()] wrists with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.") , \
						span_suicide("[user] is slitting [user.p_their()] throat with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.") , \
						span_suicide("[user] is slitting [user.p_their()] stomach open with the [src.name]! It looks like [user.p_theyre()] trying to commit seppuku.")))
	return (BRUTELOSS)

/obj/item/kitchen/knife/plastic
	name = "пластиковый нож"
	icon_state = "plastic_knife"
	inhand_icon_state = "knife"
	desc = "Очень безопасный, едва заточенный нож из пластика. Хорош для нарезки продуктов и не более того."
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_range = 5
	custom_materials = list(/datum/material/plastic = 100)
	attack_verb_continuous = list("prods", "whiffs", "scratches", "pokes")
	attack_verb_simple = list("prod", "whiff", "scratch", "poke")
	sharpness = SHARP_EDGED
	custom_price = PAYCHECK_PRISONER * 2
	var/break_chance = 25

/obj/item/kitchen/knife/plastic/afterattack(mob/living/carbon/user)
	. = ..()
	if(prob(break_chance))
		user.visible_message(span_danger("[user]'s knife snaps into tiny pieces in their hand."))
		qdel(src)

/obj/item/kitchen/knife/ritual
	name = "ритуальный серп"
	desc = "Неземные энергии, которые когда-то питали этот клинок, теперь дремлют."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "bone_blade"
	inhand_icon_state = "bone_blade"
	worn_icon_state = "bone_blade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/kitchen/knife/bloodletter
	name = "кровопускатель"
	desc = "Кинжал оккультного вида, холодный на ощупь. Каким-то образом безупречный шар на навершии полностью сделан из жидкой крови."
	icon = 'icons/obj/ice_moon/artifacts.dmi'
	icon_state = "bloodletter"
	worn_icon_state = "render"
	w_class = WEIGHT_CLASS_NORMAL
	/// Bleed stacks applied when an organic mob target is hit
	var/bleed_stacks_per_hit = 3

/obj/item/kitchen/knife/bloodletter/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!isliving(target) || !proximity_flag)
		return
	var/mob/living/M = target
	if(!(M.mob_biotypes & MOB_ORGANIC))
		return
	var/datum/status_effect/stacking/saw_bleed/bloodletting/B = M.has_status_effect(/datum/status_effect/stacking/saw_bleed/bloodletting)
	if(!B)
		M.apply_status_effect(/datum/status_effect/stacking/saw_bleed/bloodletting, bleed_stacks_per_hit)
	else
		B.add_stacks(bleed_stacks_per_hit)

/obj/item/kitchen/knife/butcher
	name = "тесак мясника"
	desc = "Огромная штука, используемая для измельчения мяса. Включая клоунов и прочее ГМО."
	icon_state = "butch"
	inhand_icon_state = "butch"
	flags_1 = CONDUCT_1
	force = 15
	throwforce = 10
	custom_materials = list(/datum/material/iron=18000)
	attack_verb_continuous = list("cleaves", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("cleave", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	w_class = WEIGHT_CLASS_NORMAL
	custom_price = PAYCHECK_EASY * 5
	wound_bonus = 25

/obj/item/kitchen/knife/hunting
	name = "охотничий нож"
	desc = "Несмотря на свое название, он в основном используется для разделки мяса мертвой добычи, а не для настоящей охоты."
	inhand_icon_state = "huntingknife"
	icon_state = "huntingknife"

/obj/item/kitchen/knife/hunting/set_butchering()
	AddComponent(/datum/component/butchering, 80 - force, 100, force + 10)

/obj/item/kitchen/knife/combat
	name = "боевой нож"
	desc = "Армейский нож для выживания."
	icon_state = "buckknife"
	embedding = list("pain_mult" = 4, "embed_chance" = 65, "fall_chance" = 10, "ignore_throwspeed_threshold" = TRUE)
	force = 20
	throwforce = 20
	attack_verb_continuous = list("slashes", "stabs", "slices", "tears", "lacerates", "rips", "cuts")
	attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "cut")
	bayonet = TRUE

/obj/item/kitchen/knife/combat/survival
	name = "нож выживальщика"
	desc = "Охотничий нож для выживания."
	icon_state = "survivalknife"
	embedding = list("pain_mult" = 4, "embed_chance" = 35, "fall_chance" = 10)
	force = 15
	throwforce = 15
	bayonet = TRUE

/obj/item/kitchen/knife/combat/bone
	name = "костяной нож"
	desc = "Заостренная кость. Абсолютный минимум для выживания."
	inhand_icon_state = "bone_dagger"
	icon_state = "bone_dagger"
	worn_icon_state = "bone_dagger"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	embedding = list("pain_mult" = 4, "embed_chance" = 35, "fall_chance" = 10)
	force = 15
	throwforce = 15
	custom_materials = null

/obj/item/kitchen/knife/combat/cyborg
	name = "нож киборга"
	desc = "Пластиковый нож киборга. Чрезвычайно острый и прочный."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "knife_cyborg"

/obj/item/kitchen/knife/shiv
	name = "стеклянная заточка"
	desc = "Твой единственный шанс на сохранение невинности если ты вдруг уронил мыло."
	icon = 'icons/obj/shards.dmi'
	icon_state = "shiv"
	inhand_icon_state = "shiv"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 8
	throwforce = 12
	attack_verb_continuous = list("shanks", "shivs")
	attack_verb_simple = list("shank", "shiv")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	custom_materials = list(/datum/material/glass=400)

/obj/item/kitchen/knife/shiv/carrot
	name = "морковная заточка"
	desc = "Не вся морковь полезна для здоровья."
	icon_state = "carrotshiv"
	inhand_icon_state = "carrotshiv"
	icon = 'icons/obj/kitchen.dmi'
	custom_materials = null

/obj/item/kitchen/knife/shiv/carrot/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] forcefully drives <b>[src]</b> into [user.p_their()] eye! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/kitchen/rollingpin
	name = "скалка"
	desc = "Использовать для вырубания бармена."
	icon_state = "rolling_pin"
	worn_icon_state = "rolling_pin"
	force = 8
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 1.5)
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("bashes", "batters", "bludgeons", "thrashes", "whacks")
	attack_verb_simple = list("bash", "batter", "bludgeon", "thrash", "whack")
	custom_price = PAYCHECK_EASY * 1.5
	tool_behaviour = TOOL_ROLLINGPIN

/obj/item/kitchen/rollingpin/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins flattening [user.p_their()] head with <b>[src]</b>! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS
/* Trays  moved to /obj/item/storage/bag */

/obj/item/kitchen/spoon
	name = "ложка"
	desc = "Один удар протянешь ножки."
	icon_state = "spoon"
	w_class = WEIGHT_CLASS_TINY
	flags_1 = CONDUCT_1
	force = 2
	throw_speed = 3
	throw_range = 5
	attack_verb_simple = list("whack", "spoon", "tap")
	attack_verb_continuous = list("whacks", "spoons", "taps")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)
	custom_materials = list(/datum/material/iron=120)
	custom_price = PAYCHECK_PRISONER * 5
	tool_behaviour = TOOL_MINING
	toolspeed = 25 // Literally 25 times worse than the base pickaxe

/obj/item/kitchen/spoon/plastic
	name = "пластиковая ложка"
	icon_state = "plastic_spoon"
	force = 0
	custom_materials = list(/datum/material/plastic=120)
	custom_price = PAYCHECK_PRISONER * 2
	toolspeed = 75 // The plastic spoon takes 5 minutes to dig through a single mineral turf... It's one, continuous, breakable, do_after...

	/// The probability of this breaking every time it's used
	var/break_chance = 25

/obj/item/kitchen/spoon/plastic/afterattack(atom/target, mob/user)
	. = ..()
	if(prob(break_chance))
		user.visible_message(span_danger("[user] смотрит на остатки сломавшейся ложки у себя в руках."))
		qdel(src)
