local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local temp = sbar.add("item", "widgets.temp", {
    position = "right",
    icon = {
        string = icons.temp,
        font = {
            style = settings.font.style_map["Bold"],
            size = 14.0
        },
        color = colors.blue
    },
    label = {
        string = "??°C",
        font = {
            family = settings.font.numbers
        },
        color = colors.white
    },
    update_freq = 1,
    padding_left = 6,
    padding_right = 6
})

temp:subscribe({"routine", "forced", "system_woke"}, function(env)
    sbar.exec("$CONFIG_DIR/helpers/temp.sh", function(temp_output)
        local temp_value = temp_output:match("([%d%.]+)")
        if temp_value then
            local temp_num = tonumber(temp_value)
            local color = colors.blue
            if temp_num then
                if temp_num >= 80 then
                    color = colors.red
                elseif temp_num >= 65 then
                    color = colors.orange
                elseif temp_num >= 50 then
                    color = colors.yellow
                end
            end
            temp:set({
                label = string.format("%.0f°C", temp_num),
                icon = { color = color }
            })
        end
    end)
end)

temp:subscribe("mouse.clicked", function(env)
    sbar.exec("osascript -e 'tell application \"System Events\" to tell process \"TG Pro\" to click menu bar item 1 of menu bar 2'")
end)

-- Background around the temp item
sbar.add("bracket", "widgets.temp.bracket", { temp.name }, {
    background = {
        color = colors.bg1,
        border_color = colors.rainbow[#colors.rainbow - 1],
        border_width = 1
    }
})

-- Padding
sbar.add("item", "widgets.temp.padding", {
    position = "right",
    width = settings.group_paddings
})
