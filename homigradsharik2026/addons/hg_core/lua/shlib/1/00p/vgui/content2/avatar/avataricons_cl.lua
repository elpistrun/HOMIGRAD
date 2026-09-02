local PANEL = oop.Reg("v_avataricons","v_avatarlist")
if not PANEL then return end

function PANEL:GetHTMLCodeTop() return false end

function PANEL:GetHTMLCode()
    return [[
    <html>
        <head>
            <meta charset="utf-8">
        </head>
        <body style="
            margin: 0;
            padding: 0;
            
            overflow-x: hidden;
            overflow-y: hidden;

            position: relative;

            display: flex;
            align-content: flex-start;
            flex-wrap: wrap;
        ">
        </body>
        
        <script>
            let height = ]] .. math.floor(self.iconSize) .. [[;
            let wide = height * 0.25

            setScrollY = function(value) {
                document.body.style.bottom = value + "px"
            }

            let list = {}

            addPanel = async (id,avatar,avatarFrame) => {
                let panel = await document.createElement("div")
                document.body.appendChild(panel)
                panel.style = `
                    width: auto;
                    height: ` + height + `px;
                    margin: ` + wide + `px;
                `

                list[id] = panel

                let avatarPanel = document.createElement("div")
                panel.appendChild(avatarPanel)
                avatarPanel.style = `
                    background-size: cover;
                    background-image: url("` + avatar + `");
                    width: ` + height + `px;
                    height: 100%;
                `

                let avatarFrameAnchor = document.createElement("div")
                avatarPanel.appendChild(avatarFrameAnchor)
                avatarFrameAnchor.style = `
                    width: 0px;
                    height: 0px;

                    position: absolute;
                `

                let avatarFramePanel = document.createElement("div")
                avatarFrameAnchor.appendChild(avatarFramePanel)
                avatarFramePanel.style = `
                    background-size: cover;
                    background-image: url("` + avatarFrame + `");

                    width: ` + (height + wide) + `px;
                    height: ` + (height + wide) + `px;

                    position: relative;
                    left: ` + (-wide / 2) + `px;
                    top: ` + (-wide / 2) + `px;
                `
            }

            removePanel = function(id) {
                list[id].remove()

                delete list[id]
            }

            setAlpha = function(id,k) {
                if (!list[id] || !list[id].style) {return}

                list[id].style.opacity = k
            }

            clear = function() {
                for (let id in list) {
                    list[id].parentNode.removeChild(list[id])
                }

                list = {}
            }
        </script>
    </html>
    ]]
end

function PANEL:AddPanel(id,avatar,avatarFrame)
    if not self.Ready then
        local thread = self:GetThread()

        thread:CreateSimple(function()
            if not IsValid(self) then return end
            if not self.Ready then return false end
            
            self:RunScript('addPanel("' .. id .. '","' .. (avatar or "") .. '","' .. (avatarFrame or "") .. '")')
        end)
    else
        self:RunScript('addPanel("' .. id .. '","' .. (avatar or "") .. '","' .. (avatarFrame or "") .. '")')
    end
end