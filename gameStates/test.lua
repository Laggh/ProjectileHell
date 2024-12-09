local thisState = {}

function thisState.load()
    hue = 0
end

function thisState.update(_Dt)
    hue = hue + 0.001
end

function thisState.draw()
    love.graphics.setColorHSV(hue, 1, 1, 1)
    love.graphics.rectangle("fill", 100, 100, 200, 200)

end

function thisState.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        changeGameState("menu")
    end
end

function thisState.mousepressed(x, y, button, istouch, presses)
    points = points + 1
end



return thisState
