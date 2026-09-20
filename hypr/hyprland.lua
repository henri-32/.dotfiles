-- ~/.config/hypr/hyprland.lua

----------------
-- MONITORE
----------------

hl.monitor({
    output = "HDMI-A-1",
    mode = "preferred",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "eDP-1",
    mode = "preferred",
    position = "0x2160",
    scale = 1,
})


----------------
-- EINGABE
----------------

hl.config({
    input = {
        kb_layout = "de",
    },
})


----------------
-- AUTOSTART
----------------

hl.on("hyprland.start", function()
    -- hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")

    -- hl.exec_cmd("mako")
    hl.exec_cmd("hyprpolkitagent")

    hl.exec_cmd("firefox")
    hl.exec_cmd("chat")
end)


----------------
-- PROGRAMME
----------------

local mod = "ALT"
local terminal = "foot"


----------------
-- PROGRAMM-BINDS
----------------

hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd(terminal))


hl.bind(
    mod .. " + D",
    hl.dsp.exec_cmd("wofi --show drun")
)

hl.bind(
    mod .. " + X",
    hl.dsp.window.close()
)

hl.bind(
    mod .. " + Z",
    hl.dsp.exec_cmd(
        "command -v hyprshutdown >/dev/null 2>&1 "
        .. "&& hyprshutdown "
        .. "|| hyprctl dispatch exit"
    )
)

hl.bind(
    mod .. " + V",
    hl.dsp.window.float({
        action = "toggle",
    })
)

hl.bind(
    mod .. " + M",
    hl.dsp.window.fullscreen({
        mode = "fullscreen",
        action = "toggle",
    })
)


----------------
-- MAUSTASTEN
----------------

hl.bind(
    "mouse:276",
    hl.dsp.exec_cmd(
        "/home/henri-32/projects/dotfiles/hypr/"
        .. "toggle-big-monitor-maximize.sh"
    ),
    {
        mouse = true,
        click = true,
    }
)

hl.bind(
    "mouse:275",
    hl.dsp.window.fullscreen({
        mode = "fullscreen",
        action = "toggle",
    }),
    {
        mouse = true,
        click = true,
    }
)


----------------
-- DISPLAY
----------------

hl.bind(
    mod .. " + O",
    function()
        hl.timer(
            function()
                hl.dispatch(
                    hl.dsp.dpms({
                        action = "toggle",
                        monitor = "eDP-1",
                    })
                )
            end,
            {
                timeout = 100,
                type = "oneshot",
            }
        )
    end
)


----------------
-- FOKUS BEWEGEN
----------------

hl.bind(
    mod .. " + H",
    hl.dsp.focus({
        direction = "l",
    })
)

hl.bind(
    mod .. " + L",
    hl.dsp.focus({
        direction = "r",
    })
)

hl.bind(
    mod .. " + K",
    hl.dsp.focus({
        direction = "u",
    })
)

hl.bind(
    mod .. " + J",
    hl.dsp.focus({
        direction = "d",
    })
)


----------------
-- MONITORFOKUS
----------------

hl.bind(
    mod .. " + comma",
    hl.dsp.focus({
        monitor = "l",
    })
)

hl.bind(
    mod .. " + period",
    hl.dsp.focus({
        monitor = "r",
    })
)


----------------
-- FENSTER BEWEGEN
----------------

hl.bind(
    mod .. " + CTRL + H",
    hl.dsp.window.move({
        direction = "l",
    })
)

hl.bind(
    mod .. " + CTRL + L",
    hl.dsp.window.move({
        direction = "r",
    })
)

hl.bind(
    mod .. " + CTRL + K",
    hl.dsp.window.move({
        direction = "u",
    })
)

hl.bind(
    mod .. " + CTRL + J",
    hl.dsp.window.move({
        direction = "d",
    })
)


----------------
-- SPEZIELLE WORKSPACES
----------------

hl.bind(
    mod .. " + CTRL + Q",
    hl.dsp.window.move({
        workspace = "special:minimized",
        follow = false,
    })
)

hl.bind(
    mod .. " + Q",
    hl.dsp.workspace.toggle_special("minimized")
)

hl.bind(
    mod .. " + CTRL + C",
    hl.dsp.window.move({
        workspace = "special:code",
        follow = false,
    })
)

hl.bind(
    mod .. " + C",
    hl.dsp.workspace.toggle_special("code")
)

hl.bind(
    mod .. " + CTRL + F",
    hl.dsp.window.move({
        workspace = "special:firefox",
        follow = false,
    })
)

hl.bind(
    mod .. " + F",
    hl.dsp.workspace.toggle_special("firefox")
)

hl.bind(
    mod .. " + CTRL + T",
    hl.dsp.window.move({
        workspace = "special:taschenrechner",
        follow = false,
    })
)

hl.bind(
    mod .. " + T",
    hl.dsp.workspace.toggle_special("taschenrechner")
)


----------------
-- VORHERIGER WORKSPACE
----------------

hl.bind(
    mod .. " + Y",
    hl.dsp.focus({
        workspace = "previous",
    })
)


----------------
-- FENSTER AUF MONITOR VERSCHIEBEN
----------------

hl.bind(
    mod .. " + CTRL + comma",
    hl.dsp.window.move({
        monitor = "eDP-1",
        follow = true,
    })
)

hl.bind(
    mod .. " + CTRL + period",
    hl.dsp.window.move({
        monitor = "HDMI-A-1",
        follow = true,
    })
)


----------------
-- WORKSPACES 1 BIS 5
----------------

for workspace = 1, 5 do
    local key = tostring(workspace)

    hl.bind(
        mod .. " + " .. key,
        hl.dsp.focus({
            workspace = workspace,
        })
    )

    hl.bind(
        mod .. " + CTRL + " .. key,
        hl.dsp.window.move({
            workspace = workspace,
            follow = true,
        })
    )
end


----------------
-- AUSSEHEN
----------------

hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,

        border_size = 1,

        col = {
            active_border = "rgb(a6da95)",
            inactive_border = "rgb(000000)",
        },
    },

    decoration = {
        active_opacity = 0.97,
        inactive_opacity = 0.85,

        blur = {
            enabled = false,
        },
    },

    animations = {
        enabled = true,
    },
})


----------------
-- ANIMATIONEN
----------------

hl.curve(
    "focusEase",
    {
        type = "bezier",
        points = {
            { 0.05, 0.9 },
            { 0.1, 1.0 },
        },
    }
)

hl.animation({
    leaf = "border",
    enabled = true,
    speed = 4,
    bezier = "focusEase",
})

hl.animation({
    leaf = "fadeSwitch",
    enabled = true,
    speed = 3,
    bezier = "focusEase",
})

hl.animation({
    leaf = "fadeDim",
    enabled = true,
    speed = 3,
    bezier = "focusEase",
})
