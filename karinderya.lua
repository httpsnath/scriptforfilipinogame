local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "oxHub", -- window title
    Icon = "door-open", -- lucide icon or "rbxassetid://" or URL. optional
    Author = "by someone lol", -- window subtitle. optional
})

local mainTab = Window:Tab({
    Title = "Main",
})

local settingsTab = Window:Tab({
    Title = "Settings",
}) 

local shopTab = Window:Tab({
    Title = "Shop",
})


getgenv().toggles = {

    autoAssign = false

}

-- Services
local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local localKariderya
for i = 1, 6 do
    local karenderya = workspace:FindFirstChild("Karenderya" .. (i == 1 and "" or i))
    
    if karenderya and karenderya:GetAttribute("Owner") == localPlayer.UserId then
        localKarinderya = karenderya
        break
    end
end

-- Remotes
local Remotes = RepStorage:WaitForChild("Remotes")
local CounterRemotes = Remotes:WaitForChild("CounterRemotes")

local GetCounterInfo = CounterRemotes:WaitForChild("GetCounterInfo")
local AssignNPC = CounterRemotes:WaitForChild("AssignNPC")


-- KarinderyaStorage
local tables = localKarenderya:FindFirstChild("DiningPlot1")



mainTab:Toggle({
    Title = "Auto Assign",
    Value = false,

    Callback = function(state)
        toggles.autoAssign = state

        if not toggles.autoAssign then
            return
        end

        while toggles.autoAssign do

            local counterInfo = GetCounterInfo:InvokeServer()

            if not counterInfo then
                task.wait(1)
                continue
            end

            local thisNpcId = counterInfo.NpcId
            local thisLamesa
            local thisIndex

            for _, lamesa in ipairs(tables:GetChildren()) do

                if not lamesa:GetAttribute("OccupiedBy1") then
                    thisLamesa = lamesa
                    thisIndex = 1
                    break
                end

                if not lamesa:GetAttribute("OccupiedBy2") then
                    thisLamesa = lamesa
                    thisIndex = 2
                    break
                end

            end

            if not thisLamesa then
                task.wait(1)
                continue
            end

            AssignNPC:InvokeServer({
                NpcId = thisNpcId,
                Seat = thisIndex,
                NPCName = thisNpcId,
                Slot = thisLamesa
            })

            task.wait(1)
        end
    end
})


})
