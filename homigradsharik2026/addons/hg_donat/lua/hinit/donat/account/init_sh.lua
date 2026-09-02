adminPanel.successRegistry("ProfileChangeBackground",nil,"rights")
adminPanel.successRegistry("ProfileBackgroundAnimated",nil,"rights")
adminPanel.successRegistry("ProfileChangeColor",nil,"rights")
adminPanel.successRegistry("ProfileSteamBackground",nil,"rights")

local function initOutfitAccount()
    if not outfitManager then return end

    function outfitManager:GetPlayerModelID(steamid64)
        return outfitManager.listData[steamid64] and outfitManager.listData[steamid64].playerModelItemID
    end

    function outfitManager:GetPlayerModel(steamid64)
        return outfitManager.listData[steamid64] and outfitManager.listData[steamid64].playerModelItem
    end
end

initOutfitAccount()
timer.Simple(0,initOutfitAccount)
