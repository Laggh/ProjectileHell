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

function summonBullet(_X,_Y,_Dir,_Hue,_Speed,_Size)
    table.insert(projectiles, {
        x = _X,
        y = _Y,
        hue = _Hue or bulletDefaultHue,
        direction = _Dir or math.random() * math.pi * 2,
        size = _Size or 10,
        speed = _Speed or bulletDefaultSpeed
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

function createProjectileRow(_StartX,_StartY,_EndX,_EndY,_Amount,_Angle,_Hue,_ProjectileSpeed,_Size)
    _Amount = math.floor(_Amount)
    local diffX = _EndX - _StartX
    local diffY = _EndY - _StartY
    for i = 0, _Amount - 1 do
        local x = _StartX + diffX * i / (_Amount - 1)
        local y = _StartY + diffY * i / (_Amount - 1)
        summonBullet(x,y,_Angle,_Hue,_ProjectileSpeed,_Size)
    end
end
function thisState.load()
    bulletDefaultHue = 0
    bulletDefaultSpeed = 6
    player = {
        x = 400,
        y = 300,
        health = 5,
        playerSpeed = 4,
        hitboxSize = 5,
    }
    projectiles = {}
    spawners = {}

    createSpawner(400,300,0,6,6000,1,function(t) return math.sin(t/20) * math.pi / 10 end)
    for i = 1, 5 do
        local x = math.random(0, 800)
        local y = math.random(0, 600)
        local hue = math.random()
        local direction = math.random() * math.pi * 2
        local size = 10
        summonBullet(x, y, direction, hue, bulletDefaultSpeed, size)
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
        v.x = v.x + math.cos(v.direction) * (v.speed or 2)
        v.y = v.y + math.sin(v.direction) * (v.speed or 2)
        if v.x < -50 or v.x > 850 or v.y < -50 or v.y > 650 then
            table.remove(projectiles, i)
        end
        local distance = math.getDistance(v.x,v.y,player.x,player.y)
        if distance < (v.size/2) + player.hitboxSize then
            player.health = player.health - 1
            table.remove(projectiles, i)
        end
    end

    local speed
    if love.keyboard.isDown("lshift") then
        speed = player.playerSpeed / 2
    else
        speed = player.playerSpeed 
    end
    if love.keyboard.isDown("w") then
        player.y = player.y - speed
    end
    if love.keyboard.isDown("s") then
        player.y = player.y + speed
    end
    if love.keyboard.isDown("a") then
        player.x = player.x - speed
    end
    if love.keyboard.isDown("d") then
        player.x = player.x + speed
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
        love.graphics.circle("fill", player.x, player.y, 10)
    end)
    love.graphics.circle("fill",player.x,player.y,6)

    --show frametime
    love.graphics.print(love.timer.getFPS(), 0, 0)
    if gmUpdateTime and gmDrawTime then
        love.graphics.print("Updt: "..gmUpdateTime, 0, 20)
        love.graphics.print("Draw: "..gmDrawTime, 0, 40)
    end
end

function thisState.keypressed(key, scancode, isrepeat)
    if key == "r" then
        createProjectileRow(0,0,800,0,800/48,UP,0)
    end

    if key == "e" then
        createProjectileRow(0+24,0,800+24,0,800/48,UP,0)
    end
    if key == "escape" then
        changeGameState("menu")
    end
end



return thisState
