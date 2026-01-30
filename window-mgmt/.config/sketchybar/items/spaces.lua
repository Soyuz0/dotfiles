local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- Register custom aerospace event
sbar.add("event", "aerospace_workspace_change")

local spaces = {}
local workspace_colors = {}

-- All letter workspaces A-Z
local all_workspaces = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}

-- Assign fixed colors to each workspace letter
for i, workspace in ipairs(all_workspaces) do
    workspace_colors[workspace] = colors.rainbow[((i - 1) % #colors.rainbow) + 1]
end

for _, workspace in ipairs(all_workspaces) do
    local ws_color = workspace_colors[workspace]
    
    local space = sbar.add("item", "space." .. workspace, {
        drawing = false,
        icon = {
            font = {
                family = settings.font.text,
                style = settings.font.style_map["Bold"],
                size = 14.0
            },
            string = workspace,
            padding_left = settings.items.padding.left,
            padding_right = settings.items.padding.left / 2,
            color = ws_color,
            highlight_color = colors.yellow,
        },
        label = {
            padding_right = settings.items.padding.right,
            color = ws_color,
            highlight_color = colors.yellow,
            font = settings.icons,
            y_offset = -1,
        },
        padding_right = 1,
        padding_left = 1,
        background = {
            color = settings.items.colors.background,
            border_width = 1,
            height = settings.items.height,
            border_color = ws_color
        },
    })

    spaces[workspace] = space

    space:subscribe("mouse.clicked", function(env)
        sbar.exec("aerospace workspace " .. workspace)
    end)
end

-- Single script to update everything at once
local function refresh_all()
    sbar.exec("aerospace list-workspaces --focused", function(focused_output)
        local focused = focused_output:gsub("%s+", "")
        
        sbar.exec("aerospace list-windows --all --format '%{workspace}|%{app-name}'", function(output)
            -- Parse all windows into workspace -> apps mapping
            local workspace_apps = {}
            for _, ws in ipairs(all_workspaces) do
                workspace_apps[ws] = {}
            end
            
            for line in output:gmatch("[^\n]+") do
                local ws, app = line:match("^(%S+)|(.+)$")
                if ws and app and workspace_apps[ws] then
                    table.insert(workspace_apps[ws], app)
                end
            end
            
            -- Update all workspaces
            for _, workspace in ipairs(all_workspaces) do
                local ws_color = workspace_colors[workspace]
                local apps = workspace_apps[workspace]
                local has_apps = #apps > 0
                local sel = workspace == focused
                
                local icon_line = ""
                for _, app in ipairs(apps) do
                    local lookup = app_icons[app]
                    local icon = ((lookup == nil) and app_icons["default"] or lookup)
                    icon_line = icon_line .. " " .. icon
                end
                
                spaces[workspace]:set({
                    drawing = has_apps or sel,
                    label = {
                        string = icon_line,
                        highlight = sel
                    },
                    icon = { highlight = sel },
                    background = {
                        color = sel and colors.with_alpha(colors.yellow, 0.2) or settings.items.colors.background,
                        border_color = sel and colors.yellow or ws_color,
                        border_width = sel and 2 or 1
                    }
                })
            end
        end)
    end)
end

-- Initial refresh
refresh_all()

-- Observer for events
local space_window_observer = sbar.add("item", {
    drawing = false,
    updates = true
})

space_window_observer:subscribe("aerospace_workspace_change", refresh_all)
space_window_observer:subscribe("space_windows_change", refresh_all)
space_window_observer:subscribe("front_app_switched", refresh_all)

-- Spaces indicator
local spaces_indicator = sbar.add("item", {
    padding_left = -3,
    padding_right = 0,
    icon = {
        padding_left = 8,
        padding_right = 9,
        color = colors.grey,
        string = icons.switch.on
    },
    label = {
        width = 0,
        padding_left = 0,
        padding_right = 8,
        string = "Spaces",
        color = colors.bg1
    },
    background = {
        color = colors.with_alpha(colors.grey, 0.0),
        border_color = colors.with_alpha(colors.bg1, 0.0)
    }
})

spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
    local currently_on = spaces_indicator:query().icon.value == icons.switch.on
    spaces_indicator:set({
        icon = currently_on and icons.switch.off or icons.switch.on
    })
end)

spaces_indicator:subscribe("mouse.entered", function(env)
    sbar.animate("tanh", 30, function()
        spaces_indicator:set({
            background = {
                color = { alpha = 1.0 },
                border_color = { alpha = 1.0 }
            },
            icon = { color = colors.bg1 },
            label = { width = "dynamic" }
        })
    end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
    sbar.animate("tanh", 30, function()
        spaces_indicator:set({
            background = {
                color = { alpha = 0.0 },
                border_color = { alpha = 0.0 }
            },
            icon = { color = colors.grey },
            label = { width = 0 }
        })
    end)
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
    sbar.trigger("swap_menus_and_spaces")
end)
