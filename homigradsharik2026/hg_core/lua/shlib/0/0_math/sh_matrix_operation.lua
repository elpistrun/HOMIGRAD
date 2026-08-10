local VMatrix = FindMetaTable("VMatrix")

VMatrix_Set = VMatrix.Set
VMatrix_Mul = VMatrix.Mul
VMatrix_Invert = VMatrix.Invert

local Matrix = Matrix
local MatrixSet = VMatrix.Set

function VMatrix:Clone()
    local matrix = Matrix()
    MatrixSet(matrix,self)
    return matrix
end


local math_sqrt = math.sqrt
local math_acos = math.acos
local math_sin  = math.sin

local Unpack = VMatrix.Unpack

function VMatrix:Lerp(t, target)
    local a11, a12, a13, a14,
          a21, a22, a23, a24,
          a31, a32, a33, a34,
          a41, a42, a43, a44 = Unpack(self)

    local b11, b12, b13, b14,
          b21, b22, b23, b24,
          b31, b32, b33, b34,
          b41, b42, b43, b44 = Unpack(target)

    -- 2. Извлечение масштаба (Scale) из векторов-столбцов и нормализация матриц
    -- Нормализация обязательна, иначе конвертация в кватернион сломается
    local sx1 = math_sqrt(a11*a11 + a21*a21 + a31*a31); sx1 = sx1 < 1e-6 and 1 or sx1
    local sy1 = math_sqrt(a12*a12 + a22*a22 + a32*a32); sy1 = sy1 < 1e-6 and 1 or sy1
    local sz1 = math_sqrt(a13*a13 + a23*a23 + a33*a33); sz1 = sz1 < 1e-6 and 1 or sz1

    local sx2 = math_sqrt(b11*b11 + b21*b21 + b31*b31); sx2 = sx2 < 1e-6 and 1 or sx2
    local sy2 = math_sqrt(b12*b12 + b22*b22 + b32*b32); sy2 = sy2 < 1e-6 and 1 or sy2
    local sz2 = math_sqrt(b13*b13 + b23*b23 + b33*b33); sz2 = sz2 < 1e-6 and 1 or sz2

    a11, a21, a31 = a11/sx1, a21/sx1, a31/sx1
    a12, a22, a32 = a12/sy1, a22/sy1, a32/sy1
    a13, a23, a33 = a13/sz1, a23/sz1, a33/sz1

    b11, b21, b31 = b11/sx2, b21/sx2, b31/sx2
    b12, b22, b32 = b12/sy2, b22/sy2, b32/sy2
    b13, b23, b33 = b13/sz2, b23/sz2, b33/sz2

    -- 3. Матрица -> Кватернион (извлекаем углы без использования Angle)
    local q1x, q1y, q1z, q1w
    local tr1 = a11 + a22 + a33
    if tr1 > 0 then
        local S = math_sqrt(tr1 + 1.0) * 2.0
        q1w, q1x, q1y, q1z = 0.25 * S, (a32 - a23) / S, (a13 - a31) / S, (a21 - a12) / S
    elseif a11 > a22 and a11 > a33 then
        local S = math_sqrt(1.0 + a11 - a22 - a33) * 2.0
        q1w, q1x, q1y, q1z = (a32 - a23) / S, 0.25 * S, (a12 + a21) / S, (a13 + a31) / S
    elseif a22 > a33 then
        local S = math_sqrt(1.0 + a22 - a11 - a33) * 2.0
        q1w, q1x, q1y, q1z = (a13 - a31) / S, (a12 + a21) / S, 0.25 * S, (a23 + a32) / S
    else
        local S = math_sqrt(1.0 + a33 - a11 - a22) * 2.0
        q1w, q1x, q1y, q1z = (a21 - a12) / S, (a13 + a31) / S, (a23 + a32) / S, 0.25 * S
    end

    local q2x, q2y, q2z, q2w
    local tr2 = b11 + b22 + b33
    if tr2 > 0 then
        local S = math_sqrt(tr2 + 1.0) * 2.0
        q2w, q2x, q2y, q2z = 0.25 * S, (b32 - b23) / S, (b13 - b31) / S, (b21 - b12) / S
    elseif b11 > b22 and b11 > b33 then
        local S = math_sqrt(1.0 + b11 - b22 - b33) * 2.0
        q2w, q2x, q2y, q2z = (b32 - b23) / S, 0.25 * S, (b12 + b21) / S, (b13 + b31) / S
    elseif b22 > b33 then
        local S = math_sqrt(1.0 + b22 - b11 - b33) * 2.0
        q2w, q2x, q2y, q2z = (b13 - b31) / S, (b12 + b21) / S, 0.25 * S, (b23 + b32) / S
    else
        local S = math_sqrt(1.0 + b33 - b11 - b22) * 2.0
        q2w, q2x, q2y, q2z = (b21 - b12) / S, (b13 + b31) / S, (b23 + b32) / S, 0.25 * S
    end

    -- 4. Сферическая линейная интерполяция (Slerp) кватернионов
    local dot = q1x*q2x + q1y*q2y + q1z*q2z + q1w*q2w
    
    -- Выбор кратчайшего пути вращения
    if dot < 0 then
        q2x, q2y, q2z, q2w = -q2x, -q2y, -q2z, -q2w
        dot = -dot
    end

    local qx, qy, qz, qw
    if dot > 0.9995 then
        -- Если углы практически идентичны, используем быстрый линейный Lerp + нормализация
        qx, qy, qz, qw = q1x + t*(q2x - q1x), q1y + t*(q2y - q1y), q1z + t*(q2z - q1z), q1w + t*(q2w - q1w)
        local len = math_sqrt(qx*qx + qy*qy + qz*qz + qw*qw)
        qx, qy, qz, qw = qx/len, qy/len, qz/len, qw/len
    else
        local theta_0 = math_acos(dot)
        local sin_theta_0 = math_sin(theta_0)
        local s0 = math_sin((1 - t) * theta_0) / sin_theta_0
        local s1 = math_sin(t * theta_0) / sin_theta_0

        qx = s0 * q1x + s1 * q2x
        qy = s0 * q1y + s1 * q2y
        qz = s0 * q1z + s1 * q2z
        qw = s0 * q1w + s1 * q2w
    end

    -- 5. Кватернион -> Матрица
    local xx, yy, zz = qx * qx, qy * qy, qz * qz
    local xy, xz, xw = qx * qy, qx * qz, qx * qw
    local yz, yw, zw = qy * qz, qy * qw, qz * qw

    -- 6. Линейная интерполяция масштаба
    local sx = sx1 + t * (sx2 - sx1)
    local sy = sy1 + t * (sy2 - sy1)
    local sz = sz1 + t * (sz2 - sz1)

    -- Собираем матрицу вращения и применяем лерпнутый масштаб
    local m11 = (1 - 2 * (yy + zz)) * sx
    local m12 = (2 * (xy - zw)) * sy
    local m13 = (2 * (xz + yw)) * sz

    local m21 = (2 * (xy + zw)) * sx
    local m22 = (1 - 2 * (xx + zz)) * sy
    local m23 = (2 * (yz - xw)) * sz

    local m31 = (2 * (xz - yw)) * sx
    local m32 = (2 * (yz + xw)) * sy
    local m33 = (1 - 2 * (xx + yy)) * sz

    -- 7. Линейная интерполяция позиции (Translation)
    local m14 = a14 + t * (b14 - a14)
    local m24 = a24 + t * (b24 - a24)
    local m34 = a34 + t * (b34 - a34)

    -- Интерполяция 4-й строки (обычно 0, 0, 0, 1)
    local m41 = a41 + t * (b41 - a41)
    local m42 = a42 + t * (b42 - a42)
    local m43 = a43 + t * (b43 - a43)
    local m44 = a44 + t * (b44 - a44)

    self:SetUnpacked(
        m11, m12, m13, m14,
        m21, m22, m23, m24,
        m31, m32, m33, m34,
        m41, m42, m43, m44
    )
end

local deg,atan2 = math.deg,math.atan2

function VMatrix:GetXYZ_PYR()
    local m11, m12, m13, m14,
          m21, m22, m23, m24,
          m31, m32, m33, m34,
          m41, m42, m43, m44 = Unpack(self)
    
    -- Вычисляем длину проекции вектора Forward на плоскость XY
    local xyDist = math_sqrt(m11 * m11 + m21 * m21)
    
    local p, y, r
    
    -- Проверка на Gimbal Lock (когда смотрим ровно вверх или вниз)
    if xyDist > 0.001 then
        p = deg(atan2(-m31, xyDist))
        y = deg(atan2(m21, m11))
        r = deg(atan2(m32, m33))
    else
        -- Если поймали Gimbal Lock, высчитываем Yaw через другие оси
        p = deg(atan2(-m31, xyDist))
        y = deg(atan2(-m12, m22))
        r = 0
    end

    return m14, m24, m34, p, y, r
end

function VMatrix:GetXYZ()
    local m11, m12, m13, m14,
          m21, m22, m23, m24,
          m31, m32, m33, m34,
          m41, m42, m43, m44 = Unpack(self)
          
    return m14, m24, m34
end

local GetXYZ = VMatrix.GetXYZ

function VMatrix:SetXYZ(vec)
    local x,y,z = GetXYZ(self)
    
    vec[1] = x
    vec[2] = y
    vec[3] = z
end

local GetXYZ_PYR = VMatrix.GetXYZ_PYR

function VMatrix:SetXYZ_PYR(vec,ang)
    local x,y,z,pitch,yaw,roll = GetXYZ_PYR(self)
    
    vec[1] = x
    vec[2] = y
    vec[3] = z

    ang[1] = pitch
    ang[2] = yaw
    ang[3] = roll
end

function VMatrix:SetPYR(ang)
    local x,y,z,pitch,yaw,roll = GetXYZ_PYR(self)

    ang[1] = pitch
    ang[2] = yaw
    ang[3] = roll
end