if CLIENT then return end
util.AddNetworkString("roundActiveName")
util.AddNetworkString("levelNextName")
util.AddNetworkString("roundActive")
util.AddNetworkString("roundData")
util.AddNetworkString("roundDataEnd")
util.AddNetworkString("roundEmit")
-- Reuse z_roundsystem_0 server logic for event levels (level_event)
-- This file ensures sv is present for z_roundsystem_1; actual logic is in z_roundsystem_0/roundsystem_sv.lua
-- Keep empty to avoid duplicate timer/hook registration, but provide file for loader completeness