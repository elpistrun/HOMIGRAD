particles2D = particles2D or {}

function particles2D:Create(passPosition)
    local self = {}
    
    local list = {}
    self.list = list

    self.gravity = {0,30}

    passPosition = passPosition or 60
    
    local drawFunction

    function self.SetDrawFunction(func) drawFunction = func end

    local start = RealTime()
    self.start = start

    function self.Time() return RealTime() - start end

    function self.Draw(w,h,ft)
        local time = RealTime() - start

        local iteration = 0
        local gravityX,gravityY = self.gravity[1],self.gravity[2]
        local friction = self.friction
        
        for i = 1,#list do
            iteration = iteration + 1
            local part = list[iteration]
            if not part then break end

            local x,y = part[1],part[2]
            local velX,velY = part[3],part[4]

            local addVelX,addVelY = velX * ft,velY * ft

            x = x + addVelX + gravityX * ft
            y = y + addVelY + gravityY * ft

            velX = velX - addVelX * friction
            velY = velY - addVelY * friction

            --

            part[1] = x
            part[2] = y

            part[3] = velX
            part[4] = velY

            if
                x <= -passPosition or x > w + passPosition or
                y <= -passPosition or y > h + passPosition or drawFunction(part,ft,time) == false
            then
                table.remove(list,iteration)
                iteration = iteration - 1

                continue
            end
        end
    end

    function self.Add(x,y,velX,velY)
        local part = {x,y,velX,velY}

        list[#list + 1] = part

        return part
    end

    return self
end