shared = {}

shared.fpsCap = 60

local libstatus, liberr = pcall(function() require('lib/discordRPC') end)

if libstatus then
    shared.discord = require('lib/discordRPC')
else
    print('[W] Discord API not found, switching to NoOp implementation.')
    function noop(...) end
    shared.discord = {
        updatePresence = noop,
        runCallbacks = noop,
        initialize = noop,
        shutdown = noop
    }
end

shared.fonts = {
    big = love.graphics.newFont('assets/fonts/standard.ttf', 36),
    std = love.graphics.newFont('assets/fonts/standard.ttf', 14),
    med = love.graphics.newFont('assets/fonts/standard.ttf', 20),
    med2 = love.graphics.newFont('assets/fonts/standard.ttf', 24),
    med3 = love.graphics.newFont('assets/fonts/standard.ttf', 26),
    title = love.graphics.newFont('assets/fonts/logo.ttf', 72)
}

shared.states = {
    MAINMENU = {
        draw = function()
            shared.text('Tetromino', 64, shared.fonts.title, { 1, 64/255, 1, 1 })
            shared.text('The Soviet mind game on crack!', 128)
            shared.text(shared.version .. ' on ' .. _VERSION, 196)
            shared.text('Press [ENTER] to play!', 300 - 32, shared.fonts.med, { 0, 1, 0, 1 })

            shared.text('Press [S] to access settings.', 600 - 80, shared.fonts.med)
            shared.text('Press [C] to access credits.', 600 - 56, shared.fonts.med)
            shared.text('Press [E] to access experiments.', 600 - 32, shared.fonts.med)
        end,
        keypress = function(key, scancode, isrepeat)
            if key == 'return' then
                shared.state = shared.states.GAMEPLAY
            end

            if key == 's' then
                shared.state = shared.states.SETTINGS
            end

            if key == 'c' then
                shared.state = shared.states.CREDITS
            end

            if key == 'e' then
                shared.state = shared.states.EXPERIMENTS
            end
        end
    },
    GAMEPLAY = {
        --[[draw = function() end,
        keypress = function(key, scancode, isrepeat) end]]
    },
    EXPERIMENTS = {
        draw = function()
            shared.text('Experiments', 32, shared.fonts.big, { 1, 64/255, 1, 1 })
            shared.text('Press [ESC] to go back.', 600 - 32, shared.fonts.med)
        end,
        keypress = function(key, scancode, isrepeat)
            if key == 'escape' then
                shared.state = shared.states.MAINMENU
            end
        end,
        cursorLoc = { 1, 1 } -- { row, column }
    },
    CREDITS = {
        draw = function()
            shared.text('Credits', 32, shared.fonts.big, { 1, 64/255, 1, 1 })
            local currentCreditPos = 128
            for k, v in pairs(shared.credits) do
                shared.text(v, currentCreditPos)
                currentCreditPos = currentCreditPos + 24
            end
            shared.text('Press [ESC] to go back.', 600 - 32, shared.fonts.med)
        end,
        keypress = function(key, scancode, isrepeat)
            if key == 'escape' then
                shared.state = shared.states.MAINMENU
            end
        end
    },
    SETTINGS = {
        draw = function()
            shared.text('Settings', 32, shared.fonts.big, { 1, 64/255, 1, 1 })
            shared.text('Use [UP/DOWN] to move cursor, [ENTER] to toggle.', 72, shared.fonts.std)
            love.graphics.setFont(shared.fonts.med)
            -- settings
            local currentLoc = 96
            for k, v in pairs(shared.settings) do
                love.graphics.setColor(v.enabled and { 0, 1, 0, 1 } or { 1, 1, 1, 1 })
                love.graphics.print(v.settingsOption, 100, currentLoc)
                currentLoc = currentLoc + 24
            end

            -- render cursor
            love.graphics.setColor({ 0.2, 0.2, 0.2, 1 })
            love.graphics.print('>', 80, ((shared.states.SETTINGS.cursorLoc - 1) * 24) + 96)

            shared.text('Press [ESC] to go back.', 600 - 32, shared.fonts.med)
        end,
        keypress = function(key, scancode, isrepeat)
            if key == 'escape' then
                shared.states.SETTINGS.cursorLoc = 1
                shared.state = shared.states.MAINMENU
            end

            if key == 'return' then
                shared.settings[shared.states.SETTINGS.cursorLoc].enabled = 
                    not shared.settings[shared.states.SETTINGS.cursorLoc].enabled
            end

            if key == 'up' then
                if shared.states.SETTINGS.cursorLoc ~= 1 then
                    shared.states.SETTINGS.cursorLoc = shared.states.SETTINGS.cursorLoc - 1
                end
            end

            if key == 'down' then
                if not ((shared.states.SETTINGS.cursorLoc + 1) > #shared.settings) then 
                    shared.states.SETTINGS.cursorLoc = shared.states.SETTINGS.cursorLoc + 1
                end
            end
        end,
        cursorLoc = 1
    }
}
shared.state = shared.states.MAINMENU

function shared.discord.presence(data)
    shared.discord.updatePresence(data)
    shared.discord.runCallbacks()
end

function shared.text(et, y, font, color)
    if not font then font = shared.fonts.med2 end
    if not color then color = { 1, 1, 1, 1 } end
    love.graphics.setFont(font)
    love.graphics.setColor(color)
    local t = font:getWidth(et)
    love.graphics.print(et, (800/2)-(t/2), y)
    love.graphics.setColor(1, 1, 1, 1)
end

shared.version = 'EARLY ACCESS VERSION'
shared.credits = {
    'Tetromino was partially based on Plumino^2.',
    '',
    'BACKGROUND MUSIC',
    '----------------',
    '"I Adore my C64" by Nicolai Heidlas',
    '"Chibi Ninja" by Erik Skiff - http://ericskiff.com/music',
    '"Korobeiniki" by The Red Army Choir',
    '"National Anthem of USSR" by The Red Army Choir',
    '"Tetris Theme A" by Nintendo',
    '',
    'FONTS',
    '-----',
    'standard.ttf -> Share Tech Mono Regular',
    'logo.ttf -> Basscrw'
}

shared.logo = love.graphics.newImage('assets/img/tetromino.png')

shared.settings = {
    {
        enabled = true,
        settingsOption = 'Show FPS Counter'
    },
    {
        enabled = false,
        settingsOption = 'Enable Experiments'
    }
}

shared.setting = {
    fpsCounter = 1
}

shared.audio = {
    error = love.audio.newSource('assets/audio/error.mp3', 'static'),
    bg = {} -- loaded in main
}

shared.currentBg = nil