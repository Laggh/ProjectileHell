function()
    RIGHT = 0
    UP = math.pi / 2
    LEFT = math.pi
    DOWN = math.pi * 3 / 2
    RED_COLOR = function() return 1,0,0,1 end
    GREEN_COLOR = function() return 0,1,0,1 end
    BLUE_COLOR = function() return 0,0,1,1 end
    YELLOW_COLOR = function() return 1,1,0,1 end
    CYAN_COLOR = function() return 0,1,1,1 end
    MAGENTA_COLOR = function() return 1,0,1,1 end
    WHITE_COLOR = function() return 1,1,1,1 end
    BLACK_COLOR = function() return 0,0,0,1 end
end()

local thisState = {}


function drawBullet(_X,_Y,_Hue,_Size)
    _Size = _Size or 12
    love.graphics.setColorHSV(_Hue, 1, 1, 1)
    love.graphics.circle("fill", _X, _Y, _Size)
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.circle("fill", _X, _Y, _Size * 2/3)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", _X, _Y, _Size * 1/3)
end

function summonBullet(_X,_Y,_Dir,_Hue,_Size)
    table.insert(projectiles, {
        x = _X,
        y = _Y,
        hue = _Hue or bulletDefaultHue,
        direction = _Dir or math.random() * math.pi * 2,
        size = _Size or 10
    })
end

function createSpawner(_X,_Y,_StartDir,_SpawnDelay,_Duration,_Spawns,_AngleFunction)
    if type(_X) == "table" then
        local spawner = _X
    else
        local spawner = {
            x = _X,
            y = _Y,
            direction = _StartDir or 0,
            spawnDelay = _SpawnDelay or 6,
            duration = _Duration or 60,
            spawns = _Spawns or 1,
            angleFunction = _AngleFunction or function() return math.random() * math.pi * 2 end,
            timer = 0
        }
    end
    table.insert(spawners, spawner)
end

function createProjectileRow(_StartX,_StartY,_EndX,_EndY,_Amount,_Angle,_Hue,_Size)
    local diffX = _EndX - _StartX
    local diffY = _EndY - _StartY
    for i = 0, _Amount - 1 do
        local x = _StartX + diffX * i / _Amount - 1
        local y = _StartY + diffY * i / _Amount - 1
        summonBullet(x,y,_Angle,_Hue,_Size)
    end

function thisState.load()
    bulletDefaultHue = 0
    player = {
        x = 400,
        y = 300,
        health = 5
    }
    projectiles = {}
    spawners = {}

    createSpawner(400,300,0,6,6000,1,function(t) return math.sin(t/20) * math.pi / 10 end)
    for i = 1, 5  do
        projectiles[i] = {
            x = math.random(0,800),
            y = math.random(0,600),
            hue = math.random(),
            direction = math.random() * math.pi * 2,
            size = 10
        }
    end
end

function thisState.update(_Dt)
    for i = #spawners, 1, -1 do
        local v = spawners[i]
        v.timer = v.timer + 1
        if v.timer % v.spawnDelay == 0 then
            for ii = 1, v.spawns do
                summonBullet(v.x, v.y,v.direction + v.angleFunction(v.timer),0)
            end
        end
        if v.timer > v.duration then
            table.remove(spawners, i)
        end
    end
    for i = #projectiles, 1, -1 do
        local v = projectiles[i]
        v.x = v.x + math.cos(v.direction) * 2
        v.y = v.y + math.sin(v.direction) * 2
        if v.x < 0 or v.x > 800 or v.y < 0 or v.y > 600 then
            table.remove(projectiles, i)
        end
        local distance = math.getDistance(v.x,v.y,400,300)
        if distance < 20 then
            -- Damage player
        end
    end
    if love.mouse.isDown(1) then
        local mx,my = love.mouse.getPosition()
        local angle = math.getAngle(mx - player.x, my - player.y)
        summonBullet(mx,my,angle,0)
    end
end

function thisState.draw()
    for i = #projectiles, 1, -1 do
        local v = projectiles[i]
        drawBullet(v.x, v.y, v.hue,v.size)
    end

    withColor(0.0, 0.5, 1.0, 1.0, function()
        love.graphics.circle("fill", player.x, player.y, 20)
    end)

    --show frametime
    love.graphics.print(love.timer.getFPS(), 0, 0)
    if gmUpdateTime and gmDrawTime then
        love.graphics.print("Updt: "..gmUpdateTime, 0, 20)
        love.graphics.print("Draw: "..gmDrawTime, 0, 40)
    end
end

function thisState.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        changeGameState("menu")
    end
end



return thisState
