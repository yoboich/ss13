/obj/item/wallframe
	icon = 'icons/obj/wallframe.dmi'
	custom_materials = list(/datum/material/iron=MINERAL_MATERIAL_AMOUNT*2)
	flags_1 = CONDUCT_1
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/result_path
	var/inverse = 0 // For inverse dir frames like light fixtures.
	var/pixel_shift //The amount of pixels
	gender = FEMALE

/obj/item/wallframe/proc/try_build(turf/on_wall, mob/user)
	if(get_dist(on_wall,user)>1)
		return
	var/ndir = get_dir(on_wall, user)
	if(!(ndir in GLOB.cardinals))
		return
	var/turf/T = get_turf(user)
	var/area/A = get_area(T)
	if(!isfloorturf(T))
		to_chat(user, span_warning("Не получится разместить [src] здесь!"))
		return
	if(A.always_unpowered)
		to_chat(user, span_warning("Не получится разместить [src] здесь!"))
		return
	if(check_wall_item(T, ndir, inverse*2))
		to_chat(user, span_warning("Здесь уже что-то есть на стене!"))
		return

	return TRUE

/obj/item/wallframe/proc/attach(turf/on_wall, mob/user)
	if(result_path)
		playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
		user.visible_message(span_notice("[user.name] прикрепляет [src] к стене.") ,
			span_notice("Прикрепляю [src] к стене.") ,
			span_hear("Слышу щёлканье."))
		var/ndir = get_dir(on_wall,user)
		if(inverse)
			ndir = turn(ndir, 180)

		var/obj/O = new result_path(get_turf(user), ndir, TRUE)
		if(pixel_shift)
			switch(ndir)
				if(NORTH)
					O.pixel_y = pixel_shift
				if(SOUTH)
					O.pixel_y = -pixel_shift
				if(EAST)
					O.pixel_x = pixel_shift
				if(WEST)
					O.pixel_x = -pixel_shift
		after_attach(O)

	qdel(src)

/obj/item/wallframe/proc/after_attach(obj/O)
	transfer_fingerprints_to(O)

/obj/item/wallframe/attackby(obj/item/W, mob/user, params)
	..()
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		// For camera-building borgs
		var/turf/T = get_step(get_turf(user), user.dir)
		if(iswallturf(T))
			T.attackby(src, user, params)

	var/metal_amt = round(custom_materials[GET_MATERIAL_REF(/datum/material/iron)]/MINERAL_MATERIAL_AMOUNT) //Replace this shit later
	var/glass_amt = round(custom_materials[GET_MATERIAL_REF(/datum/material/glass)]/MINERAL_MATERIAL_AMOUNT) //Replace this shit later

	if(W.tool_behaviour == TOOL_WRENCH && (metal_amt || glass_amt))
		to_chat(user, span_notice("Разбираю [src]."))
		if(metal_amt)
			new /obj/item/stack/sheet/iron(get_turf(src), metal_amt)
		if(glass_amt)
			new /obj/item/stack/sheet/glass(get_turf(src), glass_amt)
		qdel(src)



// APC HULL
/obj/item/wallframe/apc
	name = "рамка электрощитка"
	desc = "Используется для ремонта или создания электрощитков."
	icon_state = "apc"
	result_path = /obj/machinery/power/apc
	inverse = 1


/obj/item/wallframe/apc/try_build(turf/on_wall, user)
	if(!..())
		return
	var/turf/T = get_turf(on_wall) //the user is not where it needs to be.
	var/area/A = get_area(user)
	if(A.apc)
		to_chat(user, span_warning("Здесь уже есть электрощиток!"))
		return //only one APC per area
	if(!A.requires_power)
		to_chat(user, span_warning("Не могу установить [src] здесь!"))
		return //can't place apcs in areas with no power requirement
	for(var/obj/machinery/power/terminal/E in T)
		if(E.master)
			to_chat(user, span_warning("Здесь уже есть терминал!"))
			return
		else
			new /obj/item/stack/cable_coil(T, 10)
			to_chat(user, span_notice("Отрезаю провода старого терминала и ставлю новые."))
			qdel(E)
	return TRUE


/obj/item/electronics
	desc = "Выглядит как микросхема. Возможно."
	gender = FEMALE
	icon = 'icons/obj/module.dmi'
	icon_state = "door_electronics"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=50)
	grind_results = list(/datum/reagent/iron = 10, /datum/reagent/silicon = 10)
	custom_price = PAYCHECK_EASY * 0.5
