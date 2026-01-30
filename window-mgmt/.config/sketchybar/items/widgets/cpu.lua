local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 2.0 seconds.
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0")

local cpu = sbar.add("graph", "widgets.cpu", 42, {
	position = "right",
	graph = {
		color = colors.blue,
	},
	background = {
		height = 22,
		color = {
			alpha = 0,
		},
		border_color = {
			alpha = 0,
		},
		drawing = true,
	},
	icon = {
		drawing = false,
	},
	label = {
		drawing = false,
	},
	padding_right = settings.paddings + 6,
})

-- Overlay item for icon and label on top of graph
local cpu_label = sbar.add("item", "widgets.cpu.label", {
	position = "right",
	icon = {
		string = icons.cpu,
		font = {
			size = 12.0,
		},
		color = colors.white,
		padding_left = 4,
		padding_right = 2,
	},
	label = {
		string = "??%",
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 13.0,
		},
		color = colors.white,
		padding_right = 4,
	},
	background = {
		drawing = false,
	},
	padding_left = 0,
	padding_right = -50,
	width = 0,
})

cpu:subscribe("cpu_update", function(env)
	-- Also available: env.user_load, env.sys_load
	local load = tonumber(env.total_load)
	cpu:push({ load / 100. })

	local color = colors.blue
	if load > 30 then
		if load < 60 then
			color = colors.yellow
		elseif load < 80 then
			color = colors.orange
		else
			color = colors.red
		end
	end

	cpu:set({
		graph = {
			color = color,
		},
	})
	cpu_label:set({
		label = env.total_load .. "%",
	})
end)

cpu:subscribe("mouse.clicked", function(env)
	sbar.exec("open -na Ghostty --args -e btop")
end)

cpu_label:subscribe("mouse.clicked", function(env)
	sbar.exec("open -na Ghostty --args -e btop")
end)

-- Background around the cpu item
sbar.add("bracket", "widgets.cpu.bracket", { cpu.name }, {
	background = {
		color = colors.bg1,
		border_color = colors.rainbow[#colors.rainbow - 5],
		border_width = 1,
	},
})

-- Background around the cpu item
sbar.add("item", "widgets.cpu.padding", {
	position = "right",
	width = settings.group_paddings,
})
