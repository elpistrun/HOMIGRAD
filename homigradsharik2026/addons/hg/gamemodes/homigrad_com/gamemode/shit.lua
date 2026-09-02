AddCSLuaFile()

function GM:PlayerSpawn(ply) end
function GM:PlayerSetModel() end
function GM:PlayerLoadout() end
function GM:IsSpawnpointSuitable() end

function GM:PlayerInitialSpawn(ply) end

function GM:PlayerDeath() end
function GM:PlayerDeathThink() end

function GM:CreateTeams()
    if CreateTeams then CreateTeams() end
end

function GM:PlayerChangedTeam(ply,old,new) end
function GM:PlayerCanJoinTeam(ply,team) return hook.Run("PlayerCanJoinTeam",ply,team) end
function GM:OnPlayerChangedTeam(ply,newproxy) end--OnPlayerChangedTeam(ply,new) end

function GM:PlayerCanSeePlayersChat() end
function GM:PlayerCanHearPlayersVoice() end

function GM:PlayerStartVoice() end
function GM:PlayerEndVoice() end

function GM:ShowTeam(ply) ply:ConCommand("hg_showteam") end

function GM:MouthMoveAnimation() end
function GM:GetTeamColor(ply) return GetTeamColor and GetTeamColor(ply) or Color(255,255,255) end

GM.SecondsBetweenTeamSwitches = 1

function GM:PlayerSetModel() end
function GM:PlayerLoadout() end
function GM:PlayerDeathSound() return false end