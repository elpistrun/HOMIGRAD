//Credit to who ever made adv ballsockets & gaze for his magic ballsockets & olli for his big lau
TOOL.Category = "Constraints"
TOOL.Name = "Easy Ballsocket"

TOOL.ClientConVar[ "nocollide" ] = 0
TOOL.ClientConVar[ "axle" ] = 0 
TOOL.ClientConVar[ "flex" ] = 10

if CLIENT then
	language.Add( "tool.ebs.name", "Easy Ballsocket" )
	language.Add( "tool.ebs.listname", "Easy Ballsocket" )
	language.Add( "tool.ebs.desc", "Creates An Easy Ballsocket!" )
	language.Add( "tool.ebs.0", "Click on a wall, prop or ragdoll" )
	language.Add( "tool.ebs.1", "Now click on something else to attach it to" )
	language.Add( "tool.ebs.nocollide", "No-Collide entities" )
	language.Add( "tool.ebs.axle", "Ballsocket for axles" )
	language.Add( "tool.ebs.flex", "How much the axle can flex in degrees" )
	language.Add( "Undone_Easy Ballsocket", "Undone Easy Ballsocket" )

	function TOOL.BuildCPanel( Panel )
		Panel:AddControl("Header", {
			Text = "Easy Ballsocket", 
			Description = "#tool.ebs.desc"
		})

		Panel:AddControl("CheckBox", {
			Label = "#tool.ebs.nocollide",
			Description = "",
			Command = "ebs_nocollide"
		})
		
		Panel:AddControl("CheckBox", {
			Label = "#tool.ebs.axle", 
			Description = "",
			Command = "ebs_axle"
		})
	
		Panel:AddControl("Slider", {
			Label = "Axle flex in degrees", 
			Description = "", 
			Type = "Integer", 
			Min = "10", 
			Max = "90", 
			Command = "ebs_flex"
		})
		
	end
end

function TOOL:LeftClick( trace )
	if ( trace.Entity:IsValid() && trace.Entity:IsPlayer() ) then return end

	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	local NoCollide = self:GetClientNumber( "nocollide", 0 )
	local Axle = self:GetClientNumber( "axle", 0 ) 
	local Flex = self:GetClientNumber( "flex", 10 )
	local Dec = 0.0001
	local iNum = self:NumObjects()
	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	
	local Const = {} 
	
	self:SetObject( iNum + 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )

	if ( iNum > 0 ) then
	
		if ( CLIENT ) then return true end
		
		if ( !self:GetEnt( 1 ):IsValid() && !self:GetEnt( 2 ):IsValid() ) then 
			self:ClearObjects()
		return end
	

		local Ent1, Ent2  = self:GetEnt( 1 ), self:GetEnt( 2 )
		local Bone1, Bone2 = self:GetBone( 1 ), self:GetBone( 2 )
		local LPos1, LPos2 = self:GetLocalPos( 1 ), self:GetLocalPos( 2 )
		
		if	Axle == 0 then 	
			
			//                                                                                  xmin   ymin  zmin  xmax  ymax zmax  
			local Cons = constraint.AdvBallsocket( Ent1, Ent2, Bone1, Bone2, LPos1, LPos2, 0, 0, -180, -Dec, -Dec, 180, Dec, Dec, 0, 0, 0, 1, NoCollide )
			table.Add( Const, {Cons} )
			
			local Cons = constraint.AdvBallsocket( Ent1, Ent2, Bone1, Bone2, LPos1, LPos2, 0, 0, -180, Dec, Dec, 180, -Dec, -Dec, 0, 0, 0, 1, NoCollide )
			table.Add( Const, {Cons} )
		
			//local Cons = constraint.AdvBallsocket(Ent1, Ent2, Bone1, Bone2, LPos1, LPos2, 0, 0, -180, -0.01, -0.01, 180, 0.01, 0.01, 0, 0, 0, 1, NoCollide)
			//table.Add(Const,{Cons})
	
		else 
	
			local Cons = constraint.AdvBallsocket(Ent1, Ent2, Bone1, Bone2, LPos1, LPos2, 0, 0, -180, -Flex, -0.01, 180, Flex, 0.01, 0, 0, 0, 1, NoCollide)
			table.Add(Const,{Cons})
		
			local Cons = constraint.AdvBallsocket(Ent1, Ent2, Bone1, Bone2, LPos1, LPos2, 0, 0, -0.01, -Flex, -180, 0.01, Flex, 180, 0, 0, 0, 1, NoCollide)
			table.Add(Const,{Cons})
		
			local Cons = constraint.AdvBallsocket(Ent1, Ent2, Bone1, Bone2, LPos1, LPos2, 0, 0, -0.01, -Flex, -0.01, 0.01, Flex, 0.01, 0, 0, 0, 1, NoCollide)
			table.Add(Const,{Cons})
		
	end
	
		undo.Create( "Easy Ballsocket" )
		for k,v in pairs( Const ) do
			undo.AddEntity( v )
		end
		undo.SetPlayer( self:GetOwner() )
		undo.Finish()
	
		self:ClearObjects()		
	else
		self:SetStage( iNum+1 )	
	end
	return true
end

function TOOL:Reload( trace )
	if ( !trace.Entity:IsValid() || trace.Entity:IsPlayer() ) then return false end
	if ( CLIENT ) then return true end
	
	self:SetStage( 0 )
	return constraint.RemoveConstraints( trace.Entity, "AdvBallsocket" )
end