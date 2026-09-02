local MUTATOR = Mutator_Reg("fakeall","base",true)
if not MUTATOR then return INCLUDE_BREAK end

MUTATOR.ResetWithRound = true

MUTATOR.Title = "mutator_fakeall"
MUTATOR.Desc = "mutator_fakeall_desc"
MUTATOR.Icon = Material("icon16/group_key.png")

if SERVER then return end

function MUTATOR:CreateUI(page)
    self:CreatePanelEnabled(page)
end