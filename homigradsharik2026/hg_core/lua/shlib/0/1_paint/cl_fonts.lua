ScreenSize = ScreenSize or 1

local function update()
	local min,max

	for prio,list in pairs(ScreenSizeHooks) do
		if not min then
			min = prio
			max = prio
		else
			min = math.min(min,prio)
			max = math.max(max,prio)
		end
	end

	if not min then return end

	for i = min,max do
		for name,func in pairs(ScreenSizeHooks[i] or {}) do
			func()
		end
	end
end

function ScreenSizeUpdate()
	local mul = ScreenSize

	if ScreenSize == 1 then
		mul = (ScrW() + ScrH()) / (1920 + 1080)
	end

    event.Run("Screen Size",mul)
end

cvars.CreateOption("hg_screensize","1",function(value)
	ScreenSize = tonumber(value)

	ScreenSizeUpdate()
end,0.25,4)

hook.Add("OnScreenSizeChanged","ScreenSizeUpdate()",function()
	ScreenSizeUpdate()
end)

ScreenSizeHooks = ScreenSizeHooks or {}

function ScreenSizeHook(name,func,prio)
	prio = prio or 0

	ScreenSizeHooks[prio] = ScreenSizeHooks[prio] or {}
	ScreenSizeHooks[prio][name] = func

	update()
end

event.Add("Screen Size","Legacy Fonts",function(mul)
	-- Legacy fonts

	surface.CreateFont("H.12",{
		font = "Rubik",
		size = math.ceil(12 * mul),
		weight = 3000,
		bold = true,
		extended = false
	})

	surface.CreateFont("H.14",{
		font = "Rubik",
		size = math.ceil(14 * mul),
		weight = 3000,
		bold = true,
		extended = false
	})

	surface.CreateFont("H.18",{
		font = "Rubik",
		size = math.ceil(18 * mul),
		weight = 3000,
		extended = false
	})

	surface.CreateFont("HO.18",{
		font = "Rubik",
		size = math.ceil(18 * mul),
		weight = 3000,
		extended = false
	})

	surface.CreateFont("H.25",{
		font = "Rubik",
		size = math.ceil(25 * mul),
		weight = 3000,
		extended = false
	})

	surface.CreateFont("H.45",{
		font = "Rubik",
		size = math.ceil(45 * mul),
		weight = 3000,
		extended = false
	})

	--

	surface.CreateFont("HS.12",{
		font = "Rubik",
		size = math.ceil(12 * mul),
		weight = 1000,
		shadow = true,
		extended = false
	})

	surface.CreateFont("HS.14",{
		font = "Rubik",
		size = math.ceil(14 * mul),
		weight = 1000,
		shadow = true,
		extended = false
	})
	
	surface.CreateFont("HS.18",{
		font = "Rubik",
		size = math.ceil(18 * mul),
		weight = 3000,
		shadow = true,
		extended = false
	})

	surface.CreateFont("HOS.18",{
		font = "Rubik",
		size = math.ceil(18 * mul),
		weight = 1100,
		shadow = true,
		extended = false
	})

	surface.CreateFont("HS.25",{
		font = "Rubik",
		size = math.ceil(25 * mul),
		weight = 1100,
		shadow = true,
		extended = false
	})

	surface.CreateFont("HS.45",{
		font = "Rubik",
		size = math.ceil(45 * mul),
		weight = 1100,
		shadow = true,
		extended = false
	})
	
	surface.ClearFontCache()
end,-1)

event.Add("Screen Size","Fonts",function(mul)
	-- Legacy fonts

	surface.CreateFont("H12",{font = "Rubik Regular",size = math.ceil(12 * mul),weight = 0,extended = true})
	surface.CreateFont("HS12",{font = "Rubik Regular",size = math.ceil(12 * mul),weight = 0,extended = true,shadow = true})

	surface.CreateFont("H12Black",{font = "Rubik Black",size = math.ceil(12 * mul),weight = 0,extended = true})
	surface.CreateFont("H16",{font = "Rubik Regular",size = math.ceil(16 * mul),weight = 0,extended = true})

	surface.CreateFont("H18",{font = "Rubik Regular",size = math.ceil(18 * mul),weight = 0,extended = true})
	surface.CreateFont("HS18",{font = "Rubik Regular",size = math.ceil(18 * mul),weight = 0,extended = true,shadow = true})

	surface.CreateFont("HS18Black",{font = "Rubik Black",size = math.ceil(18 * mul),weight = 0,extended = true,shadow = true})

	surface.CreateFont("H22",{font = "Rubik Regular",size = math.ceil(22 * mul),weight = 0,extended = true})
	surface.CreateFont("H22Outline",{font = "Rubik Regular",size = math.ceil(22 * mul),weight = 0,outline = true,extended = true})
	surface.CreateFont("HS22",{font = "Rubik Regular",size = math.ceil(22 * mul),weight = 0,extended = true,shadow = true})

	surface.CreateFont("H20",{font = "Rubik Regular",size = math.ceil(20 * mul),weight = 0,extended = true})
	surface.CreateFont("HS20",{font = "Rubik Regular",size = math.ceil(20 * mul),weight = 0,extended = true,shadow = true})

	surface.CreateFont("H20Black",{font = "Rubik Black",size = math.ceil(20 * mul),weight = 0,extended = true})
	surface.CreateFont("HS20Black",{font = "Rubik Black",size = math.ceil(20 * mul),weight = 0,extended = true,shadow = true})

	surface.CreateFont("H25",{font = "Rubik Regular",size = math.ceil(25 * mul),weight = 0,extended = true})
	surface.CreateFont("HS25",{font = "Rubik Regular",size = math.ceil(25 * mul),weight = 0,extended = true,shadow = true})

	surface.CreateFont("H30",{font = "Rubik Regular",size = math.ceil(30 * mul),weight = 0,extended = true})
	surface.CreateFont("HS30",{font = "Rubik Regular",size = math.ceil(30 * mul),weight = 0,extended = true,shadow = true})

	surface.CreateFont("H50",{font = "Rubik Regular",size = math.ceil(50 * mul),weight = 0,extended = true})
	surface.CreateFont("HS50",{font = "Rubik Regular",size = math.ceil(50 * mul),weight = 0,extended = true,shadow = true})


	surface.CreateFont("H30Black",{
		font = "Rubik Black",
		size = math.ceil(30 * mul),
		weight = 0,
		extended = true
	})
end,-1)

hook.Add("InitPostEntity","Screen Size",function()
	ScreenSizeUpdate()
end)

if Initialize then
	ScreenSizeUpdate()
end