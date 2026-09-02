local max,min = math.max,math.min

function math.halfValue(value,maxvalue,k)
	k = maxvalue * k
	return max(value - k,0) / k
end

function math.halfValue2(value,maxvalue,k)
	k = maxvalue * k
	return min(value / k,1)
end

function math.safeDiv(a,b)
	if a == 0 and b == 0 then return 0 else return a / b end
end--pizdes

local random = math.random

function math.randAbs(value) return (random(0,1) == 0 and -1 or 1) end

function math.pointInBox(px,py,x,y,w,h)
	return (px >= x and px < x + w) and (py >= y and py < y + h)
end

function math.pointInBox3D(px,py,pz,x,y,z,w,h,l)
	return (px >= x and px < x + w) and (py >= y and py < y + h) and (pz >= z and pz < z + l)
end

function FakeRandom(name,min,max)
    min  = min or 0
    max  = max or 1

    -- получаем детерминированный хэш
    local crc  = util.CRC(name)
    local hash = tonumber(crc) or 0

    -- собственный PRNG (не трогаем math.randomseed)
    local x = (1103515245 * hash + 12345) % 2^31
    local frac = x / 2^31

    return min + frac * (max - min)
end

local function SmoothStep(t)
    return t * t * (3 - 2 * t)
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

function math.EvalGraph(cycle, graph)
    if cycle <= graph[1][1] then
        return graph[1][2]
    end

    if cycle >= graph[#graph][1] then
        return graph[#graph][2]
    end

    for i = 1, #graph - 1 do
        local c1, v1 = graph[i][1], graph[i][2]
        local c2, v2 = graph[i+1][1], graph[i+1][2]

        if cycle >= c1 and cycle <= c2 then
            local t = (cycle - c1) / (c2 - c1)
            t = SmoothStep(t)
            return Lerp(v1, v2, t)
        end
    end

    return graph[#graph][2]
end

function math.EvalGraphVector(cycle, graph)
    if cycle <= graph[1][1] then
        return graph[1][2]
    end

    if cycle >= graph[#graph][1] then
        return graph[#graph][2]
    end

    for i = 1, #graph - 1 do
        local c1, v1 = graph[i][1], graph[i][2]
        local c2, v2 = graph[i+1][1], graph[i+1][2]

        if cycle >= c1 and cycle <= c2 then
            local t = (cycle - c1) / (c2 - c1)
            t = SmoothStep(t)
            return LerpVector(t,v1,v2)
        end
    end

    return graph[#graph][2]
end

function math.EvalGraphAngle(cycle, graph)
    if cycle <= graph[1][1] then
        return graph[1][2]
    end

    if cycle >= graph[#graph][1] then
        return graph[#graph][2]
    end

    for i = 1, #graph - 1 do
        local c1, v1 = graph[i][1], graph[i][2]
        local c2, v2 = graph[i+1][1], graph[i+1][2]

        if cycle >= c1 and cycle <= c2 then
            local t = (cycle - c1) / (c2 - c1)
            t = SmoothStep(t)
            return LerpAngle(t,v1,v2)
        end
    end

    return graph[#graph][2]
end