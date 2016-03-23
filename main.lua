function love.load()
    TX, TY = love.window.getDesktopDimensions()
    love.window.setMode(TX, TY, {fullscreen = true})
    require 'obj'
    require 'control'
    require 'wall'
    love.graphics.setFont(love.graphics.newFont("monof56.ttf", 20))
    iconID = love.image.newImageData("images/64.png")
    love.window.setIcon(iconID)
    m = 30
    mundo = love.physics.newWorld(0, 0)
    love.physics.setMeter(m)
    wall = createWall()

    balls = {}
    gravityBalls = {}
    centers = {}
    help = 'Pressione "a" para criar uma bola\nPressione g para ativar/desativar a gravidade\nPressione "i" para informações sobre uma determinada bola\nCom o botão esquerdo, mova as bolas\nCom o botão direito você pode unir bolas\nPressione "m" para definir o tipo de união\nPressione ctrl+z para desfazer uma união' 
    cores = 'Para mudar a cor de uma bola:\nUse a bolinha do mouse (dois dedos com o touchpad) + a tecla 1, 2 ou 3\n1 para vermelho, 2 para verde e 3 para azul\nVocê pode definir uma cor padrão no retângulo contornado'
    glues = {}
    mj = nil
    mcor1 = 255
    mcor2 = 255
    mcor3 = 255

    dtr = 255
    rtr = 255
    omnigrav = false

    mraio = 10
    ballInfo = ''
    jointInit = 0
    centerBall = 0
    mode = 'distance'
end

function love.draw()

    love.graphics.setColor(255, 255, 255, 100)
    love.graphics.rectangle('fill', 0, TY - 25, TX, 25)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(string.format('help|cores|tipo de união: %s|%s gravidade: %s', mode, ballInfo, omnigrav), 0, TY - 22)
    if icores then
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(string.format('%s', cores), 2, 5)
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle('line', TX - 30, TY - 25, 30, 25)
    elseif ihelp then
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(string.format('%s', help), 2, 5)
    end
    if mouseg('help') then
        love.graphics.setColor(80, 80, 255, 60)
        love.graphics.rectangle('fill', 0, TY - 25, 40, 25)
    end
    if mouseg('cores') then
        love.graphics.setColor(80, 80, 255, 60)
        love.graphics.rectangle('fill', 50, TY - 25, 50, 25)
    end
    love.graphics.setColor(mcor1, mcor2, mcor3, 255)
    love.graphics.rectangle('fill', TX - 30, TY - 25, 30, 25)

    for i = 1, #balls, 1 do
        --love.graphics.setColor(balls[i].cor1, balls[i].cor2, balls[i].cor3)
        love.graphics.circle('line', balls[i].body:getX(), balls[i].body:getY(), balls[i].shape:getRadius())
    end
    if jointInit ~= 0 then
        if mode == 'distance' then
            love.graphics.setColor(30, 50, 180)
        else
            love.graphics.setColor(220, 140, 30)
        end
        love.graphics.line(love.mouse.getX(), love.mouse.getY(), balls[jointInit].body:getX(), balls[jointInit].body:getY())
        love.graphics.setColor(255, 255, 255, 200)
    end
    for i = 1, #glues, 1 do
        if glues[i]:getType() == 'distance' then
            love.graphics.setColor(30, 50, 180, dtr)
        else
            love.graphics.setColor(220, 140, 30, rtr)
        end
        love.graphics.line(glues[i]:getAnchors())
    end
end

function love.update(dt)
    mundo:update(dt)
    if mj then
        mj:setTarget(love.mouse.getPosition())
    end
    if love.keyboard.isDown('i') then
        for i = 1, #balls, 1 do
            if distance(love.mouse.getX(), love.mouse.getY(), balls[i].body:getX(), balls[i].body:getY()) < balls[i].shape:getRadius() then
                ballInfo = string.format('massa: %d, raio: %d', balls[i].body:getMass(), balls[i].shape:getRadius())
            end
        end
    else
        ballInfo = ''
    end
    if #gravityBalls > 0 then
        for i = 1, #balls, 1 do
            for j = 1, #gravityBalls, 1 do
                if i ~= gravityBalls[j] then
                    balls[i].body:applyForce(((m*balls[gravityBalls[j]].body:getMass())/distance(balls[gravityBalls[j]].body:getX(), balls[gravityBalls[j]].body:getY(), balls[i].body:getX(), balls[i].body:getY()))*math.cos(math.atan2(balls[gravityBalls[j]].body:getY() - balls[i].body:getY(), balls[gravityBalls[j]].body:getX() - balls[i].body:getX())), 
                        ((m*balls[gravityBalls[j]].body:getMass())/distance(balls[gravityBalls[j]].body:getX(), balls[gravityBalls[j]].body:getY(), balls[i].body:getX(), balls[i].body:getY()))*math.sin(math.atan2(balls[gravityBalls[j]].body:getY() - balls[i].body:getY(), balls[gravityBalls[j]].body:getX() - balls[i].body:getX())))
                end
            end
        end
    end
end

function love.mousepressed(mx, my, key)
    if key == 1 then
        for i = 1, #balls, 1 do
            if distance(balls[i].body:getX(), balls[i].body:getY(), mx, my) < balls[i].shape:getRadius() then
                mj = love.physics.newMouseJoint(balls[i].body, mx, my)
            end
        end
        if mx > 0 and mx < 40 and my > TY - 25 and my < TY then
            icores = false
            if ihelp then
                ihelp = false
            else
                ihelp = true
            end
        end
        if mx > 50 and mx < 100 and my > TY - 25 and my < TY then
            ihelp = false
            if icores then
                icores = false
            else
                icores = true
            end

        end
    end
    if key == 2 then
        for i = 1, #balls, 1 do
            if distance(balls[i].body:getX(), balls[i].body:getY(), mx, my) < balls[i].shape:getRadius() and jointInit == 0 then
                jointInit = i
            end
        end
    end
    if key == 4 then 
        for i = 1, #balls, 1 do
            if distance(balls[i].body:getX(), balls[i].body:getY(), mx, my) < balls[i].shape:getRadius() then
                if love.keyboard.isDown('1') then
                    balls[i].cor1 = max(balls[i].cor1 + 5, 255)
                elseif love.keyboard.isDown('2') then
                    balls[i].cor2 = max(balls[i].cor2 + 5, 255)
                elseif love.keyboard.isDown('3') then
                    balls[i].cor3 = max(balls[i].cor3 + 5, 255)
                elseif love.keyboard.isDown('d') then
                    density = balls[i].fixture:getDensity()
                    balls[i].fixture:destroy()
                    balls[i].fixture = love.physics.newFixture(balls[i].body, balls[i].shape, density + 1)
                    balls[i].fixture:setRestitution(0.9)
                else
                    mraio = balls[i].shape:getRadius() + 1
                    s = love.physics.newCircleShape(mraio)
                    d = balls[i].fixture:getDensity()
                    balls[i].fixture:destroy()
                    balls[i].shape = s
                    balls[i].fixture = love.physics.newFixture(balls[i].body, balls[i].shape, d)
                    balls[i].fixture:setRestitution(0.9)
                end
            end
        end
        if mx > TX - 30 and mx < TX and my > TY - 25 and my < TY then
            if love.keyboard.isDown('1') then
                mcor1 = max(mcor1 + 5, 255)
            elseif love.keyboard.isDown('2') then
                mcor2 = max(mcor2 + 5, 255)
            elseif love.keyboard.isDown('3') then
                mcor3 = max(mcor3 + 5, 255)
            end
        end
    end
    if key == 5 then 
        for i = 1, #balls, 1 do
            if balls[i].shape:getRadius() > 3 and distance(balls[i].body:getX(), balls[i].body:getY(), mx, my) < balls[i].shape:getRadius() then
                if love.keyboard.isDown('1') then
                    balls[i].cor1 = min(balls[i].cor1 - 5, 0)
                elseif love.keyboard.isDown('2') then
                    balls[i].cor2 = min(balls[i].cor2 - 5, 0)
                elseif love.keyboard.isDown('3') then
                    balls[i].cor3 = min(balls[i].cor3 - 5, 0)
                elseif love.keyboard.isDown('d') then
                    density = balls[i].fixture:getDensity()
                    balls[i].fixture:destroy()
                    if density > 1 then
                        balls[i].fixture = love.physics.newFixture(balls[i].body, balls[i].shape, density - 1)
                    else
                        balls[i].fixture = love.physics.newFixture(balls[i].body, balls[i].shape, 1)
                    end
                    balls[i].fixture:setRestitution(0.9)
                else
                    mraio = balls[i].shape:getRadius() - 1
                    s = love.physics.newCircleShape(mraio)
                    d = balls[i].fixture:getDensity()
                    balls[i].fixture:destroy()
                    balls[i].shape = s
                    balls[i].fixture = love.physics.newFixture(balls[i].body, balls[i].shape, d)
                    balls[i].fixture:setRestitution(0.9)
                end
            end
        end
        if mx > TX - 30 and mx < TX and my > TY - 25 and my < TY then
            if love.keyboard.isDown('1') then
                mcor1 = min(mcor1 - 5, 0)
            elseif love.keyboard.isDown('2') then
                mcor2 = min(mcor2 - 5, 0)
            elseif love.keyboard.isDown('3') then
                mcor3 = min(mcor3 - 5, 0)
            end
        end
    end
end

function love.mousereleased(mx, my, key)
    if key == 1 then
        if mj then
            mj:destroy()
            mj = nil
        end
    end
    if key == 2 then
        for i = 1, #balls, 1 do
            if jointInit ~= 0 and distance(balls[i].body:getX(), balls[i].body:getY(), mx, my) < balls[i].shape:getRadius() and jointInit ~= i then
                if mode == 'distance' then
                    table.insert(glues, love.physics.newDistanceJoint(balls[jointInit].body, balls[i].body,
                        balls[jointInit].body:getX(), balls[jointInit].body:getY(), balls[i].body:getX(), balls[i].body:getY()))
                elseif mode == 'rope' then
                    table.insert(glues, love.physics.newRopeJoint(balls[jointInit].body, balls[i].body,
                        balls[jointInit].body:getX(), balls[jointInit].body:getY(), balls[i].body:getX(), balls[i].body:getY(),
                        distance(balls[i].body:getX(), balls[i].body:getY(), balls[jointInit].body:getX(), balls[jointInit].body:getY()), true))
                end 
            end
        end
        jointInit = 0
    end
end

function love.keypressed(key)
    
    if key == 'a' then
        c = {}
        c.body = love.physics.newBody(mundo, love.mouse.getX(), love.mouse.getY(), 'dynamic')
        c.shape = love.physics.newCircleShape(mraio)
        c.fixture = love.physics.newFixture(c.body, c.shape, 10)
        c.fixture:setRestitution(0.9)
        c.cor1 = mcor1
        c.cor2 = mcor2
        c.cor3 = mcor3
        table.insert(balls, obj:new(c))
        c = nil
        if omnigrav then
            table.insert(gravityBalls, #balls)
        end
    end
    if key == 'q' then
        for i = 1, 10 do
            c = {}
            c.body = love.physics.newBody(mundo, love.math.random(TX), love.math.random(TY - 30), 'dynamic')
            c.shape = love.physics.newCircleShape(5)
            c.fixture = love.physics.newFixture(c.body, c.shape, 10)
            c.fixture:setRestitution(0.9)
            c.cor1 = mcor1
            c.cor2 = mcor2
            c.cor3 = mcor3
            table.insert(balls, obj:new(c))
            c = nil
            if omnigrav then
                table.insert(gravityBalls, #balls)
            end
        end
    end
    if key == 'b' then
        for i = 1, 50, 1 do
            c = {}
            c.body = love.physics.newBody(mundo, love.mouse.getX(), love.mouse.getY(), 'dynamic')
            c.shape = love.physics.newCircleShape(mraio)
            c.fixture = love.physics.newFixture(c.body, c.shape, 10)
            c.fixture:setRestitution(0.9)
            c.cor1 = mcor1
            c.cor2 = mcor2
            c.cor3 = mcor3
            table.insert(balls, obj:new(c))
            c = nil
            if omnigrav then
                table.insert(gravityBalls, #balls)
            end
        end
    end
    if key == 'p' then
        if not omnigrav then
            for i = 1, #balls, 1 do
                if distance(love.mouse.getX(), love.mouse.getY(), balls[i].body:getX(), balls[i].body:getY()) < balls[i].shape:getRadius() then
                    if #gravityBalls == 0 then
                        table.insert(gravityBalls, i)
                    else
                        cond = pertence(i, gravityBalls)
                        if cond then
                            table.remove(gravityBalls, cond)
                        else
                            table.insert(gravityBalls, i)
                        end
                    end
                end
            end
        end
    end
    if key == 'o' then
        for i = 1, #balls, 1 do
            if distance(love.mouse.getX(), love.mouse.getY(), balls[i].body:getX(), balls[i].body:getY()) < balls[i].shape:getRadius() then
                density = balls[i].fixture:getDensity()
                balls[i].fixture:destroy()
                balls[i].fixture = love.physics.newFixture(balls[i].body, balls[i].shape, density + 300)
                balls[i].fixture:setRestitution(0.9)
            end
        end
    end
    if key == 'l' then
        if omnigrav then
            omnigrav = false
        else
            omnigrav = true
        end
    end
    if key == 'k' then
        for i = 1, #balls, 1 do
            if distance(love.mouse.getX(), love.mouse.getY(), balls[i].body:getX(), balls[i].body:getY()) < balls[i].shape:getRadius() then


            end

        end
    end
    if key == 'up' then
        if love.keyboard.isDown('l') then
            if dtr < 255 then
                dtr = dtr + 1
            end
        end
        if love.keyboard.isDown('k') then
            if rtr < 255 then
                rtr = rtr + 1
            end
        end
    end
    if key == 'down' then
        if love.keyboard.isDown('l') then
            if dtr > 0 then
                dtr = dtr - 1
            end
        end
        if love.keyboard.isDown('k') then
            if rtr > 0 then
                rtr = rtr - 1
            end
        end
    end
    if key == 'g' then
        x, y = mundo:getGravity()
        if y > 0 then
            mundo:setGravity(0, 0)
        else
            mundo:setGravity(0, 10*m)
        end
    end
    if (love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')) and key == 'z' then
        glues[#glues]:destroy()
        table.remove(glues, #glues)
    end
    if key == 'm' then
        if mode == 'distance' then
            mode = 'rope'
        elseif mode == 'rope' then
            mode = 'distance'
        end
    end
end
