/datum/nano_module/power_monitor
	name = "Power monitor"
	var/list/grid_sensors
	var/active_sensor = null	//name_tag of the currently selected sensor

/datum/nano_module/power_monitor/New()
	..()
	refresh_sensors()

/datum/nano_module/power_monitor/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = default_state)
	var/list/data = list()
	var/list/sensors = list()
	// Focus: If it remains null if no sensor is selected and UI will display sensor list, otherwise it will display sensor reading.
	var/obj/machinery/power/sensor/focus = null
	var/turf/T = get_turf(nano_host())

	// Build list of data from sensor readings.
	for(var/obj/machinery/power/sensor/S in grid_sensors)
		sensors.Add(list(list(
		"name" = S.name_tag,
		"alarm" = S.check_grid_warning()
		)))
		if(S.name_tag == active_sensor)
			focus = S

	data["all_sensors"] = sensors
	if(focus)
		data["focus"] = focus.return_reading_data()
	data["map_levels"] = GLOB.using_map.get_map_levels(T.z)

	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "power_monitor.tmpl", "Power Monitoring Console", 800, 500, state = state)
		// adding a template with the key "mapContent" enables the map ui functionality
		ui.add_template("mapContent", "power_monitor_map_content.tmpl")
		// adding a template with the key "mapHeader" replaces the map header content
		ui.add_template("mapHeader", "power_monitor_map_header.tmpl")
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

// Refreshes list of active sensors kept on this computer.
/datum/nano_module/power_monitor/proc/refresh_sensors()
	grid_sensors = list()
	var/turf/T = get_turf(nano_host())
	var/list/levels = list()
	if(T)
		levels += GLOB.using_map.get_map_levels(T.z, FALSE)
	for(var/obj/machinery/power/sensor/S in machines)
		if(T && (S.loc.z == T.z) || (S.loc.z in levels) || (S.long_range)) // Consoles have range on their Z-Level. Sensors with long_range var will work between Z levels.
			if(S.name_tag == "#UNKN#") // Default name. Shouldn't happen!
				warning("Powernet sensor with unset ID Tag! [S.x]X [S.y]Y [S.z]Z")
			else
				grid_sensors += S

// Allows us to process UI clicks, which are relayed in form of hrefs.
/datum/nano_module/power_monitor/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["clear"] )
		active_sensor = null
	if(href_list["refresh"] )
		refresh_sensors()
	else if(href_list["setsensor"] )
		active_sensor = href_list["setsensor"]
