require('shared')

local next_time = 0
local min_dt = 1 / shared.fpsCap

function love.load()
    shared.discord.initialize('589871612392636416', true)
    shared.discord.presence({
        details = 'In Main Menu',
        largeImageKey = 'tetromino_logo',
        largeImageText = 'Tetromino'
    })
    love.graphics.setBackgroundColor({ 0.1, 0.1, 0.1 })

    local bgAudio = love.filesystem.getDirectoryItems('assets/audio/bg')
    for k, v in pairs(bgAudio) do
        table.insert(shared.audio.bg, love.audio.newSource('assets/audio/bg/' .. v, 'stream'))
    end

    math.randomseed(os.time())
    next_time = love.timer.getTime()
end

function love.quit()
    shared.discord.shutdown()
end

function love.keypressed(key, scancode, isrepeat)
    shared.state.keypress(key, scancode, isrepeat)
end

function love.update(dt)
    next_time = next_time + min_dt

    if not shared.currentBg or not shared.currentBg:isPlaying() then
        local nextTrack = math.random(1, #shared.audio.bg)
        print('random -> ' .. nextTrack)
        shared.currentBg = shared.audio.bg[nextTrack]
        shared.currentBg:play()
    end
end

function love.draw()
    shared.state.draw()

    if shared.settings[shared.setting.fpsCounter].enabled then
        love.graphics.setFont(shared.fonts.med)
        love.graphics.print(love.timer.getFPS() .. ' FPS [capped at ' .. shared.fpsCap .. ']', 1, 1)
    end

    local cur_time = love.timer.getTime()
    if next_time <= cur_time then
        next_time = cur_time
        return
    end
    love.timer.sleep(next_time - cur_time)
end