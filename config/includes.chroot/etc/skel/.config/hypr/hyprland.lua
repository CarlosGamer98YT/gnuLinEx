-- ##############################################################################
-- Configuración de Hyprland (Lua API) - gnuLinEx (Grulla)
-- Edición "Dehesa y Granito" - Inspiración Extremeña
-- Compatible con Hyprland 0.55+ / 0.56+ / 0.57+
-- ##############################################################################

------------------
---- MONITORS ----
------------------
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "wofi --show drun"
local lockscreen  = "gnulinex-lock"
local powermenu   = "gnulinex-powermenu"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function ()
    hl.exec_cmd("gnulinex-wallpaper")
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("swayidle -w timeout 600 'gnulinex-lock' timeout 900 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'gnulinex-lock'")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("/usr/lib/mate-polkit/polkit-mate-authentication-agent-1 || /usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1 || /usr/libexec/polkit-kde-authentication-agent-1")
    hl.exec_cmd("wl-paste --watch cliphist store || true")
    hl.exec_cmd("gnulinex-hardware-detect")
    hl.exec_cmd("gnulinex-battery-monitor &")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 8,
        border_size = 2,

        col = {
            -- Verde Encina (#2f6a4e) a Oro Romano (#d4a359)
            active_border   = { colors = {"rgba(2f6a4eee)", "rgba(d4a359ee)"}, angle = 45 },
            inactive_border = "rgba(2c3932aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.95,

        shadow = {
            enabled      = true,
            range        = 16,
            render_power = 3,
            color        = 0x45000000,
        },

        blur = {
            enabled  = true,
            size     = 5,
            passes   = 2,
            vibrancy = 0.18,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },

    input = {
        kb_layout  = "es",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = true,
            tap_to_click   = true,
        },
    },
})

--------------------
---- ANIMATIONS ----
--------------------
hl.curve("easeOutExpo", { type = "bezier", points = { {0.16, 1}, {0.3, 1} } })
hl.curve("smoothOut",   { type = "bezier", points = { {0.25, 0.9}, {0.3, 1} } })
hl.curve("linear",      { type = "bezier", points = { {0, 0}, {1, 1} } })

hl.animation({ leaf = "global",        enabled = true, speed = 8,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 4.5, bezier = "easeOutExpo" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.0, bezier = "easeOutExpo" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 3.8, bezier = "easeOutExpo", style = "popin 88%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 3.2, bezier = "smoothOut",   style = "popin 88%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 2.0, bezier = "linear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.8, bezier = "linear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 2.5, bezier = "easeOutExpo" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.5, bezier = "easeOutExpo" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 3.5, bezier = "easeOutExpo", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.8, bezier = "linear",       style = "fade" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 4.0, bezier = "easeOutExpo", style = "slide" })

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- Lanzadores y gestión de ventanas
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",      hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SPACE",  hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd("firefox-esr"))
hl.bind(mainMod .. " + L",      hl.dsp.exec_cmd(lockscreen))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd(powermenu))
hl.bind(mainMod .. " + X",      hl.dsp.exec_cmd(powermenu))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("gnulinex-theme-toggle"))

hl.bind(mainMod .. " + C",      hl.dsp.window.close())
hl.bind(mainMod .. " + M",      hl.dsp.exec_cmd("hyprctl dispatch exit"))
hl.bind(mainMod .. " + V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + P",      hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J",      hl.dsp.layout("togglesplit"))

-- Scratchpad
hl.bind(mainMod .. " + S",         hl.dsp.exec_cmd("hyprctl dispatch togglespecialworkspace magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspace special:magic"))

-- Capturas de pantalla
hl.bind("Print",         hl.dsp.exec_cmd("gnulinex-screenshot area"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("gnulinex-screenshot full"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("gnulinex-screenshot window"))

-- Control de audio y brillo
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("gnulinex-volume up"),     { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("gnulinex-volume down"),   { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("gnulinex-volume mute"),   { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("gnulinex-volume micmute"),{ locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("gnulinex-brightness up"),  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("gnulinex-brightness down"),{ locked = true, repeating = true })

-- Control multimedia
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Foco de ventana con flechas
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Espacios de trabajo 1 al 10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Desplazamiento de espacios de trabajo con ratón
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mover / redimensionar con ratón
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({ name = "float-pavucontrol", match = { class = "pavucontrol" },          float = true })
hl.window_rule({ name = "float-nm",          match = { class = "nm-connection-editor" }, float = true })
hl.window_rule({ name = "float-blueman",     match = { class = "blueman-manager" },      float = true })
hl.window_rule({ name = "float-imv",         match = { class = "imv" },                 float = true })
hl.window_rule({ name = "float-vlc",         match = { class = "vlc" },                 float = true })
hl.window_rule({ name = "float-ark",         match = { class = "ark" },                 float = true })
hl.window_rule({ name = "float-calamares",   match = { class = "calamares" },            float = true })
