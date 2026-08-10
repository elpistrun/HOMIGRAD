classFastManager = classFastManager or {}

function classFastManager.SpawnmenuNode(data)
    hook.Add("PopulateEntities",data.name,function(panelContent,tree,node)
        timer.Simple(0,function()
            local node

            for _,nodeFind in pairs(tree:Root():GetChildNodes()) do
                if nodeFind:GetText() != data.name then continue end

                node = nodeFind

                break
            end

            if not node then node = tree:AddNode(data.name,data.icon or "icon16/bricks.png") end

            node.DoPopulate = function(self)
                self.PropPanel = vgui.Create("ContentContainer", panelContent)
                self.PropPanel:SetVisible(false)
                self.PropPanel:SetTriggerSpawnlistChange(false)

                local order = {}
                for categoryName,data in pairs(data.category) do order[#order+1] = {categoryName,data} end
                table.sort(order,function(a,b) return (a[2].prio or 0) < (b[2].prio or 0) end)

                for i = 1,#order do
                    local info = order[i]
                    local categoryName,categoryData = info[1],info[2]
    
                    local label = vgui.Create("ContentHeader")
                    label:SetText(categoryData.printName or categoryName)

                    self.PropPanel:Add(label)

                    local order = {}
                    for name,data in pairs(categoryData.listIndex) do order[#order+1] = data end
                    if data.contentSort then table.sort(order,data.contentSort) end

                    for i = 1,#order do
                        local config = order[i]
                        local name = config.printName or config.name

                        local newpanel = spawnmenu.CreateContentIcon("entity",self.PropPanel,{
                            nicename  = name,
                            spawnname = config.name,
                            material  = config.icon or ""
                        })

                        newpanel:SetMaterial(config.icon or "")

                        function newpanel:DoClick()
                            RunConsoleCommand("hg_spawn",data.ent,config.name)
                            surface.PlaySound("ui/buttonclickrelease.wav")
                        end

                        if data.onCreateContentIcon then data.onCreateContentIcon(newpanel,config) end
                    end
                end
            end

            node.DoClick = function(self)
                self:DoPopulate()
                panelContent:SwitchPanel(self.PropPanel)
            end
        end)
    end)
end