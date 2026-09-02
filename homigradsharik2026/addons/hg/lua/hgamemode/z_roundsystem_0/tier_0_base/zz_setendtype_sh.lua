-- Server stub for Level:SetEndType. The real definition lives in
-- winner_cl.lua (client-only), but shared level files (dm, tdm, deadrun,
-- hunter, jailbreak) call it at load time on the server too.
local ok, LevelBase = pcall(oop.Get, "level_base")
if ok and LevelBase and not LevelBase.SetEndType then
    function LevelBase:SetEndType(value)
        self.EndType = value
    end
end
