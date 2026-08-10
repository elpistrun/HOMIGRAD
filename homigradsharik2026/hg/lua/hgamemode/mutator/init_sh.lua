//https://music.youtube.com/watch?v=zQkDun6VPbY&si=a0Oc2ad-Bb_GKDQH

_MutatorClasses = _MutatorClasses or {}
MutatorClasses = MutatorClasses or {}

function Mutator_Reg(class,base,isFolder) return oop.Reg(class,base,isFolder,0,_MutatorClasses) end
function Mutator_Get(class) return oop.Get(class,_MutatorClasses) end

adminPanel.commandRegistry("mutator")