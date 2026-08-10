local SWEP = oop.Get("hg_wep")
if not SWEP then return end

SWEP:Event_Add("Init","CameraLinies",function(self)
    self.CameraLinies = {}
    self.CameraLiniesIndex = {}
end)

SWEP:AttUpdate("Scope",function(self)
    for k in pairs(self.CameraLinies) do self.CameraLinies[k] = nil end
    for k in pairs(self.CameraLiniesIndex) do self.CameraLiniesIndex[k] = nil end
end,function(self,att,key)
    local cameraIndex = key[3].cameraLine or 1

    if att.ScopeHeight then
        self.CameraLinies[cameraIndex] = self.CameraLinies[cameraIndex] or {}

        local line = {
            AttachmentScope = (att.Optic or att.Holosight) and key.path,
            AttachmentPath = key.path
        }

        self.CameraLinies[cameraIndex][#self.CameraLinies[cameraIndex] + 1] = line
        self.CameraLiniesIndex[key.path] = cameraIndex
    end
end,function(self,att,key,mdl)
    if not mdl.isWorldModel or not self:IsLocal() then return end
    
    if att.Optic or att.Holosight then
        mdl.canDraw = function() return false end
    end
end)

function SWEP:PostRenderWM_Attachment(wm)
    if not self:IsLocal() then return end

    if RenderScope or not wm.isWorldModel then return end
    if not RenderIsMe() or not IsFirstRenderFrame(self,"r_fPostRenderAttachment") then return end
    
    for line,list in SortedPairs(self.CameraLinies) do
        for i = 1,#list do
            local info = list[i]

            local path = info.AttachmentScope
            if not path then continue end
            
            local key = self.attachments[path]
            local mdl = wm.attachments[path]
            
            local scopeConfig = self:GetAttachmentScopeConfig(attachmentGame.config[key[2][1]],self.cameraOption or 1)

            self:StencilScope(mdl,scopeConfig)
        end
    end
end

SWEP:Event_Add("Init","SWEP.cameraOption",function(self)
    self.cameraOption = 1
end)

local chacheConfig = {}
local chacheConfigOption = {}

function SWEP:GetAttachmentScopeConfig(attConfig,cameraOption)
    if attConfig.cameraOptions then
        if not chacheConfig[attConfig] then
            chacheConfig[attConfig] = util.tableCopy(attConfig)
        end

        chacheConfigOption[attConfig] = chacheConfigOption[attConfig] or {}

        if not chacheConfigOption[attConfig][cameraOption] then
            local tbl = util.tableCopy(chacheConfig[attConfig])
            util.tableLink(tbl,attConfig.cameraOptions[cameraOption])

            chacheConfigOption[attConfig][cameraOption] = tbl
        end

        return chacheConfigOption[attConfig][cameraOption]
    else
        return attConfig
    end
end

function SWEP:ChangeKeyFromScopeConfig(key,attConfig)
    if attConfig[key] ~= nil then self[key] = attConfig[key] else self[key] = GetClassFromName(self.ClassName)[key] end
end

function SWEP:ChangeKey(key,value)
    if value ~= nil then self[key] = value else self[key] = GetClassFromName(self.ClassName)[key] end
end

function SWEP:GetScopeInfo()
    local cameraLine = self.CameraLinies[self.cameraLine]
    if not cameraLine then return end

    cameraLine = cameraLine[1]
    if not cameraLine then return end
    
    local key = self.attachments[cameraLine.AttachmentScope]
    if not key or not IsValid(key.mdl) then return end

    return self:GetAttachmentScopeConfig(attachmentGame.config[key[2][1]],self.cameraOption),key.mdl,key
end

function SWEP:GetScopeInfoForRender()
    return self:GetScopeInfo()
end

function SWEP:AttachmentUpdateSwitchCameraOption()
    local attConfig,mdl,key = self:GetScopeInfo()
    if not attConfig then return end
    
    self.cameraOption = self.cameraOption or 1

    local scopeConfig = self:GetAttachmentScopeConfig(attConfig,self.cameraOption)

    self:ChangeKeyFromScopeConfig("CameraFollowBackRecoil",scopeConfig)
    self:ChangeKeyFromScopeConfig("RecoilBackMul",scopeConfig)
    self:ChangeKeyFromScopeConfig("ScopeSensitivity",scopeConfig)

    self.scopeSwitchStart = RealTime()
end
local delaySwitch = 0

SWEP.scopeSwitchStart = 0

event.Add("StartCommand","Weapon Scope",function(ply,cmd)
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep.GetScopeInfo then return end

    if not wep:IsScope() then return end
    
    local attConfig,mdl,key = wep:GetScopeInfo()
    if not attConfig then return end

    attConfig = attachmentGame.config[key[2][1]]

    local wheel = cmd:GetMouseWheel()
    cmd:SetMouseWheel(0)

    local time = RealTime()
    
    local cameraOptions = attConfig.cameraOptions

    if wheel ~= 0 then
        if delaySwitch < time then
            delaySwitch = time + 1 / 13

            if cameraOptions then
                wep.cameraOption = (wep.cameraOption or 0) + wheel

                if wep.cameraOption > #cameraOptions then wep.cameraOption = 0 end
                if wep.cameraOption < 0 then wep.cameraOption = #cameraOptions end
                
                sound.EmitScreen("arc9_eft_shared/weapon_light_switcher2.ogg",1,150)

                wep:AttachmentUpdateSwitchCameraOption()
            end

            if attConfig.onWheel then attConfig.onWheel(attConfig,wep,wheel) end
        end
    end
end)

SWEP:Event_Add("Deploy","AttachmentUpdateSwitchCameraOption",function(self)
    self:AttachmentUpdateSwitchCameraOption()
end)

SWEP:Event_Add("Construct Object","AttachmentUpdateSwitchCameraOption",function(self)
    self:AttachmentUpdateSwitchCameraOption()
end)

--see wep_lib_camera class