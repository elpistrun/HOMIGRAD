ammoGame = ammoGame or {}
ammoGame.config = ammoGame.config or {}

ammoGame.callibreIndex = ammoGame.callibreIndex or {}
ammoGame.callibresList = ammoGame.callibresList or {}

ammoGame.uiInvUse = ammoGame.uiInvUse or {}

function ammoGame.Reg(data)
    data.category = data.AmmoCalibre

    classFastManager.RegCategory(ammoGame.callibresList,data.category)

    return classFastManager.Reg(ammoGame.config,nil,ammoGame.callibresList,data.name,data)
end

classFastManager.RegCategory(ammoGame.callibresList,"other",{prio = 10})