//Engineering Mesons

#define MODE_NONE ""
#define MODE_MESON "Мезонный сканер"
#define MODE_TRAY "Терагерцовый сканер"
#define MODE_RAD "Радиационный сканер"
#define MODE_SHUTTLE "shuttle"
#define MODE_PIPE_CONNECTABLE "connectable"

/obj/item/clothing/glasses/meson/engine
	name = "многофункциональные инженерные очки"
	desc = "Очки, используемые инженерами. Режим <b>Мезонного сканера</b> позволяет просматривать основные структурные и рельефные ландшафты сквозь стены, режим <b>Терагерцового сканера</b> позволяет видеть объекты под полом, такие как кабели и трубы, а режим <b>Радиационного сканера</b> позволяет видеть объекты, загрязненные излучением."
	icon_state = "trayson-meson"
	inhand_icon_state = "trayson-meson"
	actions_types = list(/datum/action/item_action/toggle_mode)
	glass_colour_type = /datum/client_colour/glass_colour/gray

	vision_flags = NONE
	darkness_view = 2
	invis_view = SEE_INVISIBLE_LIVING

	var/list/modes = list(MODE_NONE = MODE_MESON, MODE_MESON = MODE_TRAY, MODE_TRAY = MODE_RAD, MODE_RAD = MODE_NONE)
	var/mode = MODE_NONE
	var/range = 4
	var/list/connection_images = list()

/obj/item/clothing/glasses/meson/engine/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	update_icon()

/obj/item/clothing/glasses/meson/engine/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/clothing/glasses/meson/engine/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/glasses/meson/engine/proc/toggle_mode(mob/user, voluntary)
	mode = modes[mode]
	to_chat(user, "<span class='[voluntary ? "notice":"warning"]'>[voluntary ? "Переключаю очки":"Очки переключаются"] [mode ? "в режим [mode]":"в режим ВЫКЛ."][voluntary ? ".":"!"]</span>")
	if(connection_images.len)
		connection_images.Cut()
	switch(mode)
		if(MODE_MESON)
			vision_flags = SEE_TURFS
			darkness_view = 1
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			change_glass_color(user, /datum/client_colour/glass_colour/yellow)

		if(MODE_TRAY) //undoes the last mode, meson
			vision_flags = NONE
			darkness_view = 2
			lighting_alpha = null
			change_glass_color(user, /datum/client_colour/glass_colour/lightblue)

		if(MODE_PIPE_CONNECTABLE)
			change_glass_color(user, /datum/client_colour/glass_colour/lightblue)

		if(MODE_RAD)
			change_glass_color(user, /datum/client_colour/glass_colour/lightgreen)

		if(MODE_SHUTTLE)
			change_glass_color(user, /datum/client_colour/glass_colour/red)

		if(MODE_NONE)
			change_glass_color(user, initial(glass_colour_type))

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.glasses == src)
			H.update_sight()

	update_icon()
	update_item_action_buttons()

/obj/item/clothing/glasses/meson/engine/attack_self(mob/user)
	toggle_mode(user, TRUE)

/obj/item/clothing/glasses/meson/engine/process()
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/user = loc
	if(user.glasses != src || !user.client)
		return
	switch(mode)
		if(MODE_TRAY)
			t_ray_scan(user, 8, range)
		if(MODE_RAD)
			show_rads()
		if(MODE_SHUTTLE)
			show_shuttle()
		if(MODE_PIPE_CONNECTABLE)
			show_connections()

/obj/item/clothing/glasses/meson/engine/proc/show_rads()
	var/mob/living/carbon/human/user = loc
	var/list/rad_places = list()
	for(var/datum/component/radioactive/thing in SSradiation.processing)
		var/atom/owner = thing.parent
		var/turf/place = get_turf(owner)
		if(rad_places[place])
			rad_places[place] += thing.strength
		else
			rad_places[place] = thing.strength

	for(var/i in rad_places)
		var/turf/place = i
		if(get_dist(user, place) >= range*5)	//Rads are easier to see than wires under the floor
			continue
		var/strength = round(rad_places[i] / 1000, 0.1)
		var/image/pic = image(loc = place)
		var/mutable_appearance/MA = new()
		MA.maptext = MAPTEXT("[strength]k")
		MA.color = "#04e604"
		MA.plane = GAME_PLANE
		pic.appearance = MA
		flick_overlay(pic, list(user.client), 10)

/obj/item/clothing/glasses/meson/engine/proc/show_shuttle()
	var/mob/living/carbon/human/user = loc
	var/obj/docking_port/mobile/port = SSshuttle.get_containing_shuttle(user)
	if(!port)
		return
	var/list/shuttle_areas = port.shuttle_areas
	for(var/area/region as anything in shuttle_areas)
		for(var/turf/place as anything in region.get_contained_turfs())
			if(get_dist(user, place) > 7)
				continue
			var/image/pic
			if(isshuttleturf(place))
				pic = new('icons/turf/overlays.dmi', place, "greenOverlay", AREA_LAYER)
			else
				pic = new('icons/turf/overlays.dmi', place, "redOverlay", AREA_LAYER)
			flick_overlay(pic, list(user.client), 8)

/obj/item/clothing/glasses/meson/engine/proc/show_connections()
	var/mob/living/carbon/human/user = loc

	for(var/obj/machinery/atmospherics/pipe/smart/smart in connection_images)
		if(get_dist(loc, smart.loc) > range)
			connection_images -= smart

	for(var/obj/machinery/atmospherics/pipe/smart/smart in orange(range, user))
		if(!connection_images[smart])
			connection_images[smart] = list()
		for(var/direction in GLOB.cardinals)
			if(!(smart.get_init_directions() & direction))
				continue
			if(!connection_images[smart][dir2text(direction)])
				var/image/arrow
				arrow = new('icons/obj/atmospherics/pipes/simple.dmi', get_turf(smart), "connection_overlay")
				arrow.dir = direction
				arrow.layer = smart.layer
				arrow.color = smart.pipe_color
				PIPING_LAYER_DOUBLE_SHIFT(arrow, smart.piping_layer)
				connection_images[smart][dir2text(direction)] = arrow
			if(connection_images.len)
				flick_overlay(connection_images[smart][dir2text(direction)], list(user.client), 1.5 SECONDS)

/obj/item/clothing/glasses/meson/engine/update_icon_state()
	. = ..()
	switch(mode)
		if(MODE_TRAY)
			icon_state = "trayson-t-ray"
			inhand_icon_state = "trayson-t-ray"
			worn_icon_state = "trayson-t-ray"
		if(MODE_RAD)
			icon_state = "trayson-radiation"
			inhand_icon_state = "trayson-radiation"
			worn_icon_state = "trayson-radiation"
		if(MODE_MESON)
			icon_state = "trayson-meson"
			inhand_icon_state = "trayson-meson"
			worn_icon_state = "trayson-meson"
		if(MODE_NONE)
			icon_state = "trayson-"
			inhand_icon_state = "trayson-"
			worn_icon_state = "trayson-"

/obj/item/clothing/glasses/meson/engine/tray //atmos techs have lived far too long without tray goggles while those damned engineers get their dual-purpose gogles all to themselves
	name = "Терагерцовые очки"
	icon_state = "trayson-t-ray"
	inhand_icon_state = "trayson-t-ray"
	desc = "Используется инженерным персоналом для наблюдения за объектами под полом, такими как кабели и трубы."
	range = 5

	modes = list(MODE_NONE = MODE_TRAY, MODE_TRAY = MODE_PIPE_CONNECTABLE, MODE_PIPE_CONNECTABLE = MODE_NONE)

/obj/item/clothing/glasses/meson/engine/tray/dropped(mob/user)
	. = ..()
	if(connection_images.len)
		connection_images.Cut()

/obj/item/clothing/glasses/meson/engine/shuttle
	name = "сканер зоны для шаттла"
	icon_state = "trayson-shuttle"
	inhand_icon_state = "trayson-shuttle"
	desc = "Используется для определения границ зоны прилета шаттла."

	modes = list(MODE_NONE = MODE_SHUTTLE, MODE_SHUTTLE = MODE_NONE)

#undef MODE_NONE
#undef MODE_MESON
#undef MODE_TRAY
#undef MODE_RAD
#undef MODE_SHUTTLE
#undef MODE_PIPE_CONNECTABLE
