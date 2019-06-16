require('shared')

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
end

function love.quit()
    shared.discord.shutdown()
end

function love.keypressed(key, scancode, isrepeat)
    shared.state.keypress(key, scancode, isrepeat)
end

function love.update()
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
        love.graphics.print(love.timer.getFPS() .. ' FPS', 1, 1)
    end
end