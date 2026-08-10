local ITEM = inventoryManager:ItemReg("halflife_pass","role_base",true)
if not ITEM then return INCLUDE_BREAK end

ITEM.RaryType = "common"
ITEM.Color = Color(255,125,0)
ITEM.Name = "HALFLIFE 2 COOP PASS"
ITEM.Desc = "Боевой пропуск на сервер с режимом HalfLife 2 Coop\nроходите уровни халф лайфа и зарабатывайте валюту за переход на следующую карту и убийства враждебных NPC."

ITEM.WorldModel = "models/weapons/w_crowbar.mdl"
ITEM.WorldVector = Vector(30,-1.3,-3)
ITEM.WorldAngle = Angle(45,-90,180)

ITEM.ActivatedTitle = "Вы активировали пропуск!"

function ITEM:GetTimeLess() return 60 * 60 * 6 end

if SERVER then return end
