local ITEM = inventoryManager:ItemReg("combat_pass","role_base",true)
if not ITEM then return INCLUDE_BREAK end

ITEM.RaryType = "common"
ITEM.Color = Color(255,0,0)
ITEM.Name = "ZOMBIE SURVIVAL PASS"
ITEM.Desc = "Боевой пропуск на сервер с режимом Zombie Survival\nОтбивайтесь от волн зомби, лутайте ящики и приносити их в приёмники получая за это игровые монеты!\nС каждым разом волны будут всё сложнее.\nАктивируется на 6 часов, в течении 6 часов вы можете находится насервере BATTLE PASS"

ITEM.WorldModel = "models/Lamarr.mdl"
ITEM.WorldVector = Vector(40,1,-7)
ITEM.WorldAngle = Angle(0,25,0)

ITEM.ActivatedTitle = "Вы активировали пропуск!"

function ITEM:GetTimeLess() return 60 * 60 * 6 end

if SERVER then return end
