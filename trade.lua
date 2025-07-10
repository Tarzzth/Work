loadstring(game:HttpGet("https://raw.githubusercontent.com/Tarzzth/API/refs/heads/main/main.lua"))()

local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

function Player()
    return game:GetService("Players")
end

function LocalPlayer()
    return Player().LocalPlayer
end

function Character()
    return LocalPlayer().Character or LocalPlayer().CharacterAdded:Wait()
end

function Humanoid(Character)
    return Character:FindFirstChildOfClass("Humanoid")
end

function RootPart(Character)
    return Character:FindFirstChild("HumanoidRootPart")
end

function PlayerGui()
    return game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
end
if _G.API.Trade_gag == false then
    LocalPlayer():Kick("API DOWN")
end
_G.Configs = _G.Configs or {}

local Remote = {
    ["trade_pet"] = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("PetGiftingService")
}

local Log = {
    SendGift = 0,
}

function Click(ui)
    if GuiService.SelectedObject == ui then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    elseif GuiService.SelectedObject ~= ui then
        GuiService.SelectedObject = ui
    end
end

function Equip_ITEM(item)
    if not item then return warn("Not Found Item") end
    local Backpack = LocalPlayer():FindFirstChild("Backpack")
    local Humanoid = LocalPlayer().Character and LocalPlayer().Character:FindFirstChildOfClass("Humanoid")

    Humanoid:UnequipTools()
    if Backpack then
        local tool = Backpack:FindFirstChild(item)
        if not tool then 
            local tool_char = LocalPlayer().Character:FindFirstChild(item)
            if tool_char then
                return
            end
        end

        if tool then
            if tool:IsA("Tool") then
                Humanoid:EquipTool(tool)
            end
        end
    end
end

function Trade(player , item , type)
    local suss, err = pcall(function()
        local player = Player():FindFirstChild(player)
        if not player then return warn("ไม่เจอ ผู้เล่น : "..tostring(player)) end

        local RootPart = RootPart(Character())
        RootPart.CFrame = CFrame.new(player.character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))

        Equip_ITEM(item)
        if type == "Pet" then
            local args = {
                "GivePet",
                player
            }
            Remote["trade_pet"]:FireServer(unpack(args))
        else
            local promt = player.character:FindFirstChild("HumanoidRootPart"):FindFirstChild("ProximityPrompt")
            if not promt then return end
            if promt and promt.Enabled then
                promt.HoldDuration = 0
                fireproximityprompt(promt , 0)
            end
        end
    end)
    if not suss then warn("Trade Error:", err) end
end

function GET_PETS()
    local suss, result = pcall(function()
        local Pet = nil
        local Backpack = LocalPlayer():FindFirstChild("Backpack")
        if not Backpack then return end

        for i, v in pairs(Backpack:GetChildren()) do
            if v:IsA("Tool") and v:GetAttribute("ItemType") == "Pet" or v:GetAttribute("PetType") == "Pet" then
                if _G.Configs.Pet_Select == true then
                    for i, keyword in pairs(_G.Configs.Pet) do
                        local name = keyword:lower()
                        if v.Name:lower():find(name) then
                            Pet = v
                            return Pet
                        end
                    end
                else
                    Pet = v
                    return Pet
                end
            end
        end
        return Pet
    end)
    if suss then return result else warn("GET_PETS Error:", result) end
end

function GET_FRUIT()
    local suss, result = pcall(function()
        local Fruit = nil
        local Backpack = LocalPlayer():FindFirstChild("Backpack")
        if not Backpack then return end

        for i, v in pairs(Backpack:GetChildren()) do
            if v:IsA("Tool") and v:GetAttribute("b") == "j" then
                if _G.Configs.Fruit_Select == true then
                    for i, keyword in pairs(_G.Configs.Fruit) do
                        local name = keyword:lower()
                        if v.Name:lower():find(name) then
                            Fruit = v
                            return Fruit
                        end
                    end
                else
                    Fruit = v
                    return Fruit
                end
            end
        end
        return Fruit
    end)
    if suss then return result else warn("GET_FRUIT Error:", result) end
end

function Update_ITEM()
    local suss, err = pcall(function()
        local Storge = {}
        local Backpack = LocalPlayer():FindFirstChild("Backpack")
        if not Backpack then return end

        for i, key in pairs(_G.Configs.ItemLimit) do
            if not key.IsReady then
                Storge[i] = {}
                for _, item in pairs(Backpack:GetChildren()) do
                    if item:IsA("Tool") and item.Name:lower():find(i:lower()) then
                        table.insert(Storge[i], item)
                    end
                end

                if #Storge[i] >= _G.Configs.ItemLimit[i].Count then
                    _G.Configs.ItemLimit[i].IsReady = true
                    warn("มีผลไม้ " .. i .. " ในกระเป๋าแล้ว จำนวน: " .. #Storge[i])
                end
            end
        end
    end)
    if not suss then warn("Update_ITEM Error:", err) end
end

function Check_item()
    local suss, err = pcall(function()
        local readyCount = 0
        local readyItems = {}

        for name, data in pairs(_G.Configs.ItemLimit) do
            if data.IsReady then
                readyCount += 1
                table.insert(readyItems, name)
            end
        end

        local totalItems = 0
        for _ in pairs(_G.Configs.ItemLimit) do
            totalItems += 1
        end

        if readyCount >= totalItems then
            warn("ครบตามเงื่อนไขผลไม้แล้ว: " .. table.concat(readyItems, ", "))
            LocalPlayer():Kick("มีผลไม้ครบตามที่กำหนดไว้แล้ว: " .. table.concat(readyItems, ", "))
            return true
        else
            warn("ยังไม่ครบผลไม้ที่กำหนดไว้: " .. table.concat(readyItems, ", "))
            return false
        end
    end)
    if not suss then warn("Check_item Error:", err) end
end

function Trade_PET()
    local suss, err = pcall(function()
        local Pet = GET_PETS()
        if Pet then
            Trade(_G.Configs.Player , Pet.Name , "Pet")
        end
    end)
    if not suss then warn("Trade_PET Error:", err) end
end

function Trade_Fruit()
    local suss, err = pcall(function()
        local fruit = GET_FRUIT()
        if fruit then
            Trade(_G.Configs.Player , fruit.Name , "Fruit")
        end
    end)
    if not suss then warn("Trade_Fruit Error:", err) end
end

function Accept()
    local suss , err = pcall(function()
        local PlayerGui = PlayerGui()
        local Gift_Notification = PlayerGui:FindFirstChild("Gift_Notification")
        local Frame = Gift_Notification and Gift_Notification:FindFirstChild("Frame")
        if Frame then
            local Holder = Frame:FindFirstChild("Gift_Notification"):FindFirstChild("Holder")
            if Holder then
                local Frame2 = Holder:FindFirstChild("Frame")
                if Frame2 then
                    local Accept = Frame2:FindFirstChild("Accept")
                    if Accept then
                        Click(Accept)
                    end
                end    
            end
        end
    end)
    if not suss then warn("Accept Error:", err) end
end


_G.Workspace = true

task.spawn(function()
    while _G.Workspace do task.wait()
        if _G.Configs.AutoTrade.Fruit then
            Trade_Fruit()
        end
    end
end)

task.spawn(function()
    while _G.Workspace do task.wait()
        if _G.Configs.AutoTrade.Pet then
            Trade_PET()
        end
    end
end)

task.spawn(function()
    while _G.Workspace do task.wait()
        if _G.Configs.AutoAccept then
            Accept()
        end
        
    end
end)

task.spawn(function()
    while _G.Workspace do task.wait(5)
        Update_ITEM()
        if Check_item() then
            _G.Workspace = false
        end
    end
end)

