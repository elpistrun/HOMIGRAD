local ENT = oop.Reg("ent_lootbox_attachment","ent_lootbox_base")
if not ENT then return end

ENT.PrintName = "LootBox Attachment"

ENT.WorldModel = "models/homigrad/creates/supply2.mdl"
ENT.WorldSkin = 2
ENT.WorldColor = Color(45,75,25)

ENT.w = 3
ENT.h = 2

function ENT:GetRandomCount() return 6 end

function ENT:CreateLoot()
    local list = {}

    local aviableAttachments = {}
    for k,v in pairs(WeaponAttachments_EntitiesList) do aviableAttachments[k] = v end
    
    local aviablePackages = {}
    for k,v in pairs(WeaponAttachments_PackageBoxsList) do aviablePackages[k] = v end
    
    for i = 1,self:GetRandomCount() do
        local item

        if i == 1 then
            local content,packageName = table.Random(aviablePackages)
            aviableAttachments[packageName] = nil

            item = {
                spawnname = "wep_att_package",
                data = {
                    packageName = packageName
                }
            }
        else
            local content,attName = table.Random(aviableAttachments)
            aviableAttachments[attName] = nil
            
            item = {
                spawnname = content.entityName or "wep_att_base",
                data = {
                    attachmentName = attName
                }
            }
        end

        self.inv:AddEnt(item)
    end
end