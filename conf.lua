function love.conf(t)
    t.window.width = 800
    t.window.height = 600
    t.window.title = "Tetromino"
    t.window.icon = "assets/img/tetromino.png"
    t.identity = "tetromino"
end

function love.errorhandler(err)
    love.audio.stop()
    shared.audio.error:play()

    love.graphics.reset()
    love.graphics.setFont(shared.fonts.big)

    local function draw()
        love.graphics.clear({ 0.05, 0.05, 0.05 })

        shared.text("Ow...", 32, shared.fonts.title, { 1, 0, 0, 1 })
        shared.text("Tetromino crashed.", 128, shared.fonts.med2)
        shared.text("(not good)", 128+32, shared.fonts.med2)
        shared.text("Please report to the developers!", 128+64, shared.fonts.med)
        shared.text("(unless you were playing with a ton of experiments)", 128+64+32, shared.fonts.std)
        shared.text("DEBUG: ", 128+128, shared.fonts.med2)
        shared.text(err, 128+128+32, shared.fonts.med)
        shared.text("Press [ENTER] to quit.", 600-32, shared.fonts.med)

        love.graphics.present()
    end

    return function()
        love.event.pump()
    
        for e, a, b, c in love.event.poll() do
            if e == "quit" then
                return 1
            elseif e == "keypressed" and a == "return" then
                return 1
            end
        end

        draw()
        love.timer.sleep(0.1)
    end
end