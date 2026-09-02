
--[[
	Credits: Akabenko&EskiDost
	https://steamcommunity.com/id/amede/
	https://steamcommunity.com/id/EskiDost

	Subpixel Morphological Anti-Aliasing (SMAA)
	https://github.com/iryoku/smaa/tree/master
]]

local shaderName = "SMAA"

local r_smaa = CreateClientConVar( "r_smaa", "0", true, false, "Enable/Disable SMAA.", 0, 1 )
local r_smaa_edgedetect = CreateClientConVar( "r_smaa_edgedetect", "0", true, false, "SMAA EDGE DETECTION TYPE.", 0, 2 )
local r_smaa_threshold = CreateClientConVar( "r_smaa_threshold", "0.1", true, false, "SMAA THRESHOLD.", 0, 0.5 )
local r_smaa_max_search_steps = CreateClientConVar( "r_smaa_max_search_steps", "32", true, false, "SMAA MAX SEARCH STEPS.", 0, 112 )
local r_smaa_max_search_steps_diag = CreateClientConVar( "r_smaa_max_search_steps_diag", "16", true, false, "SMAA MAX SEARCH STEPS DIAG.", 0, 20 )
local r_smaa_corner_rounding = CreateClientConVar( "r_smaa_corner_rounding", "25", true, false, "SMAA CORNER ROUNDING.", 0, 100 )
local r_smaa_debug = CreateClientConVar( "r_smaa_debug", "0", false, false, "SMAA DEBUG MODE.", 0, 2 )
local r_smaa_debug_show = CreateClientConVar( "r_smaa_debug_show", "0", true, false, "SMAA SHOW CHANGES.", 0, 1 )

list.Set( "PostProcess", "#r_smaa.name", {
	["icon"] = "gui/postprocess/smaa.jpg",
	["convar"] = r_smaa:GetName(),
	["category"] = "#shaders_pp",
	["cpanel"] = function( panel )

		panel:Help( "#r_smaa.info" )

		panel:AddControl( "ComboBox", {
			["MenuButton"] = 1,
			["Folder"] = "smaa",
			["Options"] = {
				[ "#preset.default" ] = {
					[ r_smaa:GetName() ] = r_smaa:GetDefault(),
					[ r_smaa_threshold:GetName() ] = r_smaa_threshold:GetDefault(),
					[ r_smaa_max_search_steps:GetName() ] = r_smaa_max_search_steps:GetDefault(),
					[ r_smaa_max_search_steps_diag:GetName() ] = r_smaa_max_search_steps_diag:GetDefault(),
					[ r_smaa_corner_rounding:GetName() ] = r_smaa_corner_rounding:GetDefault(),
					[ r_smaa_debug:GetName() ] = r_smaa_debug:GetDefault(),
					[ r_smaa_debug_show:GetName() ] = r_smaa_debug_show:GetDefault(),
				},

				[ "#preset.smaa.low" ] = {
					[ r_smaa:GetName() ] = "1",
					[ r_smaa_threshold:GetName() ] = "0.15",
					[ r_smaa_max_search_steps:GetName() ] = "4",
					[ r_smaa_max_search_steps_diag:GetName() ] = r_smaa_max_search_steps_diag:GetDefault(),
					[ r_smaa_corner_rounding:GetName() ] = r_smaa_corner_rounding:GetDefault(),
				},

				[ "#preset.smaa.medium" ] = {
					[ r_smaa:GetName() ] = "1",
					[ r_smaa_threshold:GetName() ] = "0.1",
					[ r_smaa_max_search_steps:GetName() ] = "8",
					[ r_smaa_max_search_steps_diag:GetName() ] = r_smaa_max_search_steps_diag:GetDefault(),
					[ r_smaa_corner_rounding:GetName() ] = r_smaa_corner_rounding:GetDefault(),
				},

				[ "#preset.smaa.high" ] = {
					[ r_smaa:GetName() ] = "1",
					[ r_smaa_threshold:GetName() ] = "0.1",
					[ r_smaa_max_search_steps:GetName() ] = "16",
					[ r_smaa_max_search_steps_diag:GetName() ] = "8",
					[ r_smaa_corner_rounding:GetName() ] = "25",
				},

				[ "#preset.smaa.ultra" ] = {
					[ r_smaa:GetName() ] = "1",
					[ r_smaa_threshold:GetName() ] = "0.05",
					[ r_smaa_max_search_steps:GetName() ] = "32",
					[ r_smaa_max_search_steps_diag:GetName() ] = "16",
					[ r_smaa_corner_rounding:GetName() ] = "25",
				},
			},
			["CVars"] = {
				r_smaa:GetName(),
				r_smaa_threshold:GetName(),
				r_smaa_max_search_steps:GetName(),
				r_smaa_max_search_steps_diag:GetName(),
				r_smaa_corner_rounding:GetName(),
				r_smaa_debug:GetName(),
				r_smaa_debug_show:GetName(),
			}
		} )

		panel:AddControl( "CheckBox", { Label = "#r_smaa.enable", Command = r_smaa:GetName() } )

		local options_t = {
			[ "#r_smaa.edge_detection_color" ] = {
				[ r_smaa_edgedetect:GetName() ] = "0",
			},

			[ "#r_smaa.edge_detection_luma" ] = {
				[ r_smaa_edgedetect:GetName() ] = "1",
			},
		}

		if GSHADER then
			options_t[ "#r_smaa.edge_detection_depth" ] = {
			 	[ r_smaa_edgedetect:GetName() ] = "2", -- depth
			}
		end

		panel:AddControl( "combobox", {
			["Label"] = "#r_smaa.edge_detection_type",
			["Command"] = r_smaa_edgedetect:GetName(),
			["Options"] = options_t,
			["CVars"] = {
				r_smaa_edgedetect:GetName(),
			},
			["Help"] = false,
		} )

		panel:AddControl( "Slider", {
			["Label"] = "#r_smaa.threshold",
			["Command"] = r_smaa_threshold:GetName(),
			["Min"] = tostring( r_smaa_threshold:GetMin() ),
			["Max"] = tostring( r_smaa_threshold:GetMax() ),
			["Type"] = "Float",
			["Help"] = false
		} )

		panel:AddControl( "Slider", {
			["Label"] = "#r_smaa.max_search_steps",
			["Command"] = r_smaa_max_search_steps:GetName(),
			["Min"] = tostring( r_smaa_max_search_steps:GetMin() ),
			["Max"] = tostring( r_smaa_max_search_steps:GetMax() ),
			["Type"] = "Float",
			["Help"] = false
		} )

		panel:AddControl( "Slider", {
			["Label"] = "#r_smaa.max_search_steps_diag",
			["Command"] = r_smaa_max_search_steps_diag:GetName(),
			["Min"] = tostring( r_smaa_max_search_steps_diag:GetMin() ),
			["Max"] = tostring( r_smaa_max_search_steps_diag:GetMax() ),
			["Type"] = "Float",
			["Help"] = false
		} )

		panel:AddControl( "Slider", {
			["Label"] = "#r_smaa.corner_rounding",
			["Command"] = r_smaa_corner_rounding:GetName(),
			["Min"] = tostring( r_smaa_corner_rounding:GetMin() ),
			["Max"] = tostring( r_smaa_corner_rounding:GetMax() ),
			["Type"] = "Float",
			["Help"] = false
		} )

		panel:AddControl( "combobox", {
			["Label"] = "#r_smaa.debug",
			["Command"] = r_smaa_debug:GetName(),
			["Options"] = {
				[ "#r_smaa.view_disabled" ] = {
					[ r_smaa_debug:GetName() ] = "0",
				},

				[ "#r_smaa.view_edges" ] = {
					[ r_smaa_debug:GetName() ] = "1",
				},

				[ "#r_smaa.view_weights" ] = {
					[ r_smaa_debug:GetName() ] = "2",
				},
			},
			["CVars"] = {
				r_smaa_debug:GetName(),
			},
			["Help"] = false,
		} )

		panel:AddControl( "CheckBox", { Label = "#r_smaa.debug_show", Command = r_smaa_debug_show:GetName() } )

	end
} )

local edge_detect_mats = {
	Material("shaders/SMAAEdgeDetection_color");
	Material("shaders/SMAAEdgeDetection_luma");
	Material("shaders/smaaedgedetection_depth");
}

local SMAAEdgeDetection = edge_detect_mats[ math.Clamp( math.Round( r_smaa_edgedetect:GetInt() + 1 ), 0, r_smaa_edgedetect:GetMax() + 1 ) ]

local SMAABlendingWeight = Material("shaders/SMAABlendingWeight")
local SMAANeighborhood = Material("shaders/SMAANeighborhood")

local rtFlags = render.GetHDREnabled() and CREATERENDERTARGETFLAGS_HDR or 0

local rt = GetRenderTargetEx("_rt_SMAAEdgeDetection", ScrW(), ScrH(),
	RT_SIZE_FULL_FRAME_BUFFER,
	MATERIAL_RT_DEPTH_NONE,
	bit.bor(4, 8, 256, 512),
	rtFlags,
	IMAGE_FORMAT_RGB565
	-- IMAGE_FORMAT_RGBA8888
)

IMAGE_FORMAT_BGRA4444 = 19

local rt2 = GetRenderTargetEx("_rt_SMAABlendingWeight", ScrW(), ScrH(),
	RT_SIZE_FULL_FRAME_BUFFER,
	MATERIAL_RT_DEPTH_NONE,
	bit.bor(4, 8, 256, 512),
	rtFlags,
	IMAGE_FORMAT_BGRA4444
	--IMAGE_FORMAT_RGBA8888
)

local screentexture = render.GetScreenEffectTexture()

local COMPARE_SMAA
local DEBUG_MAT

local color_0_255_0 = Color( 0, 255, 0, 255 )
local color_0_255_255 = Color( 0, 255, 255, 255 )
local color_red = Color( 255, 0, 0 )

local function SMAA()
    render.UpdateScreenEffectTexture()
    render.CopyRenderTargetToTexture(screentexture)

    render.PushRenderTarget(rt)
        render.Clear(0,0,0,0)
        render.SetMaterial(SMAAEdgeDetection)
        render.DrawScreenQuad()
    render.PopRenderTarget()

    render.PushRenderTarget(rt2)
        render.Clear(0,0,0,0)
        render.SetMaterial(SMAABlendingWeight)
        render.DrawScreenQuad()
    render.PopRenderTarget()

    if COMPARE_SMAA then
        local x,y = gui.MousePos()

        render.SetMaterial(DEBUG_MAT or SMAANeighborhood)
        render.SetScissorRect( 0,0,x,ScrH(), true ) 
            render.DrawScreenQuad()
        render.SetScissorRect( 0, 0, 0, 0, false )

        surface.SetDrawColor( color_red )
        surface.DrawLine(x, 0, x, ScrH() )

        draw.DrawText("SMAA", "BudgetLabel", math.Clamp(100, 0,x-10), 50,color_0_255_0, TEXT_ALIGN_RIGHT)
        draw.DrawText("DEFAULT", "BudgetLabel", math.Clamp(ScrW() - 100, x + 10, ScrW()), 50, color_0_255_255, TEXT_ALIGN_LEFT)
    else
    	render.SetMaterial(DEBUG_MAT or SMAANeighborhood)
    	render.DrawScreenQuad()
    end
end

if r_smaa:GetBool() then hook.Add("RenderScreenspaceEffects", shaderName, SMAA) end
cvars.AddChangeCallback( r_smaa:GetName(), function( convar_name, _, identifier )
	local activate = identifier == "1"

	if activate then
		hook.Add("RenderScreenspaceEffects", shaderName, SMAA)
	else
		hook.Remove("RenderScreenspaceEffects", shaderName)
	end
end, shaderName )

local DebugTextures = {
	SMAAEdgeDetection,
	SMAABlendingWeight,
}

DEBUG_MAT = DebugTextures[ r_smaa_debug:GetInt() ]
cvars.AddChangeCallback( r_smaa_debug:GetName(), function( convar_name, _, identifier )
	DEBUG_MAT = DebugTextures[ tonumber(identifier) ]
end, shaderName )

local SMAAConfig = {
	[r_smaa_threshold:GetName()] = {"$c0_x", r_smaa_threshold},
	[r_smaa_max_search_steps:GetName()] = {"$c0_y", r_smaa_max_search_steps},
	[r_smaa_max_search_steps_diag:GetName()] = {"$c0_z", r_smaa_max_search_steps_diag},
	[r_smaa_corner_rounding:GetName()] = {"$c0_w", r_smaa_corner_rounding},
}

local function SMAASetFloat(convar_name, _, value)
	if convar_name == "r_smaa_threshold" and r_smaa_edgedetect:GetInt() == 2 then
		value = tonumber(value) * 0.025 * 0.1 -- depth treshold
	end

	SMAAEdgeDetection:SetFloat(SMAAConfig[convar_name][1], value)
	SMAABlendingWeight:SetFloat(SMAAConfig[convar_name][1], value)
	SMAANeighborhood:SetFloat(SMAAConfig[convar_name][1], value)
end

local function InitSMAAParams()
	for k, v in pairs(SMAAConfig) do
		SMAASetFloat(k, nil, v[2]:GetFloat())
	end
end

timer.Simple(0, function()
	InitSMAAParams()
end)

cvars.AddChangeCallback( r_smaa_threshold:GetName(), SMAASetFloat, shaderName )
cvars.AddChangeCallback( r_smaa_max_search_steps:GetName(), SMAASetFloat, shaderName )
cvars.AddChangeCallback( r_smaa_max_search_steps_diag:GetName(), SMAASetFloat, shaderName )
cvars.AddChangeCallback( r_smaa_corner_rounding:GetName(), SMAASetFloat, shaderName )


cvars.AddChangeCallback( r_smaa_edgedetect:GetName(), function(convar_name, _, identifier) 
	SMAAEdgeDetection = edge_detect_mats[ tonumber( identifier ) + 1 ]
	print(SMAAEdgeDetection)
	DebugTextures[1] = SMAAEdgeDetection
	DEBUG_MAT = DebugTextures[ r_smaa_debug:GetInt() ]
	InitSMAAParams()
end, shaderName )


COMPARE_SMAA = r_smaa_debug_show:GetBool()
cvars.AddChangeCallback( r_smaa_debug_show:GetName(), function( convar_name, _, identifier )
	COMPARE_SMAA = identifier == "1"
end, shaderName )