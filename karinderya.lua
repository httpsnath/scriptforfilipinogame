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
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

-- Debug helper
local function debugPrint(...)
    print("[oxHub][AutoAssign]", ...)
end

-- Find player's Karenderya
local localKarenderya

debugPrint("Searching for player's Karenderya...")

for i = 1, 6 do
    local karenderyaName = "Karenderya" .. (i == 1 and "" or i)
    local karenderya = workspace:FindFirstChild(karenderyaName)

    debugPrint(
        "Checking:",
        karenderyaName,
        "Found:",
        karenderya ~= nil
    )

    if karenderya
        and karenderya:GetAttribute("Owner") == localPlayer.UserId
    then
        localKarenderya = karenderya

        debugPrint(
            "Found owned Karenderya:",
            localKarenderya.Name
        )

        break
    end
end

if not localKarenderya then
    warn("[oxHub] Could not find player's Karenderya")
    return
end

-- Dining plot
local tables = localKarenderya:FindFirstChild("DiningPlot1")

if not tables then
    warn("[oxHub] DiningPlot1 not found")
    return
end

debugPrint("DiningPlot1 found:", tables:GetFullName())

-- Remotes
local Remotes = RepStorage:WaitForChild("Remotes")
local CounterRemotes = Remotes:WaitForChild("CounterRemotes")

local GetCounterInfo = CounterRemotes:WaitForChild("GetCounterInfo")
local AssignNPC = CounterRemotes:WaitForChild("AssignNPC")

debugPrint("Remotes loaded")


mainTab:Toggle({
    Title = "Auto Assign",
    Value = false,

    Callback = function(state)

        toggles.autoAssign = state

        debugPrint("Toggle changed:", state)

        if not state then
            debugPrint("Auto Assign disabled")
            return
        end

        debugPrint("Auto Assign enabled")

        while toggles.autoAssign do

            debugPrint("----- New assignment attempt -----")

            --------------------------------------------------
            -- Get NPC from counter
            --------------------------------------------------

            local counterInfo = GetCounterInfo:InvokeServer()

            if not counterInfo then
                debugPrint("No counter info returned")
                task.wait(1)
                continue
            end

            debugPrint("CounterInfo received")

            if not counterInfo.NpcId then
                debugPrint("CounterInfo has no NpcId")
                task.wait(1)
                continue
            end

            local thisNpcId = counterInfo.NpcId

            debugPrint("NPC ID:", thisNpcId)


            --------------------------------------------------
            -- Find available table
            --------------------------------------------------

            local thisLamesa
            local thisIndex

            -- Explicitly loop Table1 -> Table12
            for tableNumber = 1, 12 do

                if not toggles.autoAssign then
                    break
                end

                local tableName = "Table" .. tableNumber
                local lamesa = tables:FindFirstChild(tableName)

                if not lamesa then
                    debugPrint(
                        tableName,
                        "does not exist"
                    )

                    continue
                end

                debugPrint(
                    "Checking",
                    tableName
                )


                --------------------------------------------------
                -- CurrentTable check
                --------------------------------------------------

                local currentTable = lamesa:FindFirstChild("CurrentTable")

                if not currentTable then

                    debugPrint(
                        tableName,
                        "-> CurrentTable folder missing"
                    )

                    continue
                end

                local currentTableContents = currentTable:GetChildren()

                if #currentTableContents == 0 then

                    debugPrint(
                        tableName,
                        "-> CurrentTable is EMPTY"
                    )

                    continue
                end

                debugPrint(
                    tableName,
                    "-> CurrentTable occupied by:",
                    currentTableContents[1].Name
                )


                --------------------------------------------------
                -- CurrentChair check
                --------------------------------------------------

                local currentChair = lamesa:FindFirstChild("CurrentChair")

                if not currentChair then

                    debugPrint(
                        tableName,
                        "-> CurrentChair folder missing"
                    )

                    continue
                end


                --------------------------------------------------
                -- Check Chair 1
                --------------------------------------------------

                local placedChair1 =
                    currentChair:FindFirstChild("PlacedChair1")

                if placedChair1 then

                    local occupiedBy1 =
                        lamesa:GetAttribute("OccupiedBy1")

                    debugPrint(
                        tableName,
                        "-> PlacedChair1 exists | OccupiedBy1:",
                        occupiedBy1
                    )

                    if not occupiedBy1 then

                        thisLamesa = lamesa
                        thisIndex = 1

                        debugPrint(
                            "FOUND AVAILABLE SEAT:",
                            tableName,
                            "Seat 1"
                        )

                        break
                    end
                end


                --------------------------------------------------
                -- Check Chair 2
                --------------------------------------------------

                local placedChair2 =
                    currentChair:FindFirstChild("PlacedChair2")

                if placedChair2 then

                    local occupiedBy2 =
                        lamesa:GetAttribute("OccupiedBy2")

                    debugPrint(
                        tableName,
                        "-> PlacedChair2 exists | OccupiedBy2:",
                        occupiedBy2
                    )

                    if not occupiedBy2 then

                        thisLamesa = lamesa
                        thisIndex = 2

                        debugPrint(
                            "FOUND AVAILABLE SEAT:",
                            tableName,
                            "Seat 2"
                        )

                        break
                    end
                end


                debugPrint(
                    tableName,
                    "-> No available seat"
                )
            end


            --------------------------------------------------
            -- No available table
            --------------------------------------------------

            if not thisLamesa then

                debugPrint(
                    "No available table/seat found"
                )

                task.wait(1)
                continue
            end


            --------------------------------------------------
            -- Assign NPC
            --------------------------------------------------

            debugPrint(
                "Assigning NPC:",
                thisNpcId,
                "to:",
                thisLamesa.Name,
                "Seat:",
                thisIndex
            )

            local result = AssignNPC:InvokeServer({
                NpcId = thisNpcId,
                Seat = thisIndex,
                NPCName = thisNpcId,
                Slot = thisLamesa
            })

            debugPrint(
                "AssignNPC result:",
                result
            )

            task.wait(1)
        end

        debugPrint("Auto Assign loop stopped")
    end
})