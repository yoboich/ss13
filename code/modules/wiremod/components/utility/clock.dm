/**
 * # Clock Component
 *
 * Fires every tick of the circuit timer SS
 */
/obj/item/circuit_component/clock
	display_name = "Тактовый генератор"
	desc = "Компонент, который периодически срабатывает."
	category = "Utility"

	/// Whether the clock is on or not
	var/datum/port/input/on

	/// The signal from this clock component
	var/datum/port/output/signal

/obj/item/circuit_component/clock/get_ui_notices()
	. = ..()
	. += create_ui_notice("Clock Interval: [DisplayTimeText(COMP_CLOCK_DELAY)]", "orange", "clock")

/obj/item/circuit_component/clock/populate_ports()
	on = add_input_port("Включено", PORT_TYPE_NUMBER)

	signal = add_output_port("Сигнал", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/clock/input_received(datum/port/input/port)

	if(on.value)
		start_process()
	else
		stop_process()

/obj/item/circuit_component/clock/Destroy()
	stop_process()
	return ..()

/obj/item/circuit_component/clock/process(delta_time)
	signal.set_output(COMPONENT_SIGNAL)

/**
 * Adds the component to the SSclock_component process list
 *
 * Starts ticking to send signals between periods of time
 */
/obj/item/circuit_component/clock/proc/start_process()
	START_PROCESSING(SSclock_component, src)

/**
 * Removes the component to the SSclock_component process list
 *
 * Signals stop getting sent.
 */
/obj/item/circuit_component/clock/proc/stop_process()
	STOP_PROCESSING(SSclock_component, src)
