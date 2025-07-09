loadstring(game:HttpGet("https://raw.githubusercontent.com/Tarzzth/API/refs/heads/main/main.lua"))()
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

function Equip_ITEM(item)
    pcall(function()
        local Character = Character()
        local Humanoid = Character:FindFirstChild("Humanoid")
        local Backpack = LocalPlayer():FindFirstChild("Backpack")
        if not Humanoid then return end

        local _item = Backpack:FindFirstChild(tostring(item))
        if _item then
            Humanoid:EquipTool(_item)
        else
            return warn("Not Found ITEM in backpack")
        end
    end)
end

function Trade(player , item , type)
    pcall(function()
        local player = Player():FindFirstChild(player)
        if not player then return warn("ไม่เจอ ผู้เล่น : "..tostring(player)) end

        local RootPart = RootPart(Character())
        RootPart.CFrame = CFrame.new(player.character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))

        Equip_ITEM(item)
        -- trade
        if type == "Pet" then
            local args = {
                "GivePet",
                player
            }
        Remote.trade_pet:FireServer(unpack(args))
            Log.SendGift += 1
        else
            local promt = player.character:FindFirstChild("HumanoidRootPart"):FindFirstChild("ProximityPrompt")
            if not promt then return end

            if promt and promt.Enabled then
                promt.HoldDuration = 0
                fireproximityprompt(promt , 0 ,function()
                    Log.SendGift += 1
                end)
            end
        end
    end)
end
function GET_PETS()
    pcall(function()
        local Pet = nil

        local Backpack = LocalPlayer():FindFirstChild("Backpack")
        if not Backpack then return end

        for i, v in pairs(Backpack:GetChildren()) do
            if v:IsA("Tool") and v:GetAttribute("ItemType") == "Pet" then
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
end

function GET_FRUIT()
    pcall(function()
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
end

function Update_ITEM()
    pcall(function()
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
end

function Check_item()
    pcall(function()
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
end


function Trade_PET()
    pcall(function()
        if Log.SendGift >= _G.Configs.Limit_Item then
            return
        end
    
        local Pet = GET_PETS()
        Trade(_G.Configs.Player , Pet , "Pet")
    end)
end

function Trade_Fruit()
    pcall(function()
        if Log.SendGift >= _G.Configs.Limit_Item then
            return
        end
    
        local fruit = GET_FRUIT()
        Trade(_G.Configs.Player , fruit , "Fruit")
    end)
end

function Accept()
    local suss , err = pcall(function()
        local PlayerGui = PlayerGui()
        local Gift_Notification = PlayerGui:FindFirstChild("Gift_Notification")
        local Frame = Gift_Notification:FindFirstChild("Frame")
        if Frame then
            local Holder = Frame:FindFirstChild("Gift_Notification"):FindFirstChild("Holder")
            if Holder then
                local Frame2 = Holder:FindFirstChild("Frame")
                if Frame2 then
                    local Accept = Frame2:FindFirstChild("Accept")
                    if Accept then
                        firesignal(Accept.MouseButton1Click)
                    end
                end    
            end
        end
    end)
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
    while _G.Workspace do task.wait()
        if _G.Configs.Enable_limit then
            Update_ITEM()
            Check_item()
        end
    end
end)
