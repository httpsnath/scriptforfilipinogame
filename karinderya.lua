local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "oxHub",
    Icon = "door-open",
    Author = "by someone lol",
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
    autoAssign = false,
    autoServe = false
}


-- Services
local RepStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")

local localPlayer = Players.LocalPlayer


-- Debug helper
local function debugPrint(...)
    print("[oxHub]", ...)
end


--------------------------------------------------
-- Find player's Karenderya
--------------------------------------------------

local localKarenderya

debugPrint("Searching for player's Karenderya...")

for i = 1, 6 do

    local karenderyaName =
        "Karenderya" .. (i == 1 and "" or i)

    local karenderya =
        workspace:FindFirstChild(karenderyaName)

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


--------------------------------------------------
-- Dining Plot
--------------------------------------------------

local tables =
    localKarenderya:FindFirstChild("DiningPlot1")

if not tables then
    warn("[oxHub] DiningPlot1 not found")
    return
end

debugPrint(
    "DiningPlot1 found:",
    tables:GetFullName()
)


--------------------------------------------------
-- Serve folder
--------------------------------------------------

local serveFolder =
    localKarenderya:FindFirstChild("Serve")

if not serveFolder then
    warn("[oxHub] Serve folder not found")
else
    debugPrint(
        "Serve folder found:",
        serveFolder:GetFullName()
    )
end


--------------------------------------------------
-- Remotes
--------------------------------------------------

local Remotes =
    RepStorage:WaitForChild("Remotes")

local CounterRemotes =
    Remotes:WaitForChild("CounterRemotes")

local GetCounterInfo =
    CounterRemotes:WaitForChild("GetCounterInfo")

local AssignNPC =
    CounterRemotes:WaitForChild("AssignNPC")

debugPrint("Remotes loaded")


--------------------------------------------------
-- Character helper
--------------------------------------------------

local function getCharacter()

    local character =
        localPlayer.Character

    if not character then
        return nil, nil, nil
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local rootPart =
        character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not rootPart then
        return nil, nil, nil
    end

    return character, humanoid, rootPart
end


--------------------------------------------------
-- Pathfind to part
--------------------------------------------------

local function walkToPart(targetPart)

    local character, humanoid, rootPart =
        getCharacter()

    if not character then

        debugPrint(
            "Character/Humanoid/RootPart not found"
        )

        return false
    end


    debugPrint(
        "Pathfinding to:",
        targetPart.Name
    )


    local path =
        PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
            AgentCanClimb = true,
        })


    local success, errorMessage =
        pcall(function()

            path:ComputeAsync(
                rootPart.Position,
                targetPart.Position
            )

        end)


    if not success then

        debugPrint(
            "Path computation failed:",
            errorMessage
        )

        return false
    end


    if path.Status ~= Enum.PathStatus.Success then

        debugPrint(
            "No valid path to:",
            targetPart.Name,
            "Status:",
            path.Status.Name
        )

        return false
    end


    local waypoints =
        path:GetWaypoints()

    debugPrint(
        "Path found:",
        #waypoints,
        "waypoints"
    )


    for index, waypoint in ipairs(waypoints) do

        if not toggles.autoServe then

            debugPrint(
                "Auto Serve disabled during path"
            )

            return false
        end


        if waypoint.Action ==
            Enum.PathWaypointAction.Jump
        then

            humanoid.Jump = true
        end


        humanoid:MoveTo(
            waypoint.Position
        )


        local reached =
            humanoid.MoveToFinished:Wait()


        if not reached then

            debugPrint(
                "Failed to reach waypoint:",
                index
            )

            return false
        end

    end


    debugPrint(
        "Reached:",
        targetPart.Name
    )

    return true
end


--------------------------------------------------
-- Auto Serve
--------------------------------------------------

local function serveIteration()

    if not serveFolder then

        debugPrint(
            "Cannot serve: Serve folder missing"
        )

        return
    end


    debugPrint(
        "========== SERVE ITERATION START =========="
    )


    --------------------------------------------------
    -- Serve 1 -> Serve 12
    --------------------------------------------------

    for i = 1, 12 do

        if not toggles.autoServe then

            debugPrint(
                "Auto Serve disabled."
            )

            return
        end


        local servePart =
            serveFolder:FindFirstChild(
                tostring(i)
            )


        if not servePart then

            debugPrint(
                "Serve",
                i,
                "does not exist -> skipping"
            )

            continue
        end


        debugPrint(
            "Checking Serve",
            i
        )


        --------------------------------------------------
        -- Check children
        --------------------------------------------------

        local children =
            servePart:GetChildren()


        if #children == 0 then

            debugPrint(
                "Serve",
                i,
                "has no children -> skipping"
            )

            continue
        end


        --------------------------------------------------
        -- Get random-named child
        --------------------------------------------------

        local container =
            children[1]


        debugPrint(
            "Serve",
            i,
            "container:",
            container.Name
        )


        --------------------------------------------------
        -- Find ProximityPrompt recursively
        --------------------------------------------------

        local prompt =
            container:FindFirstChildWhichIsA(
                "ProximityPrompt",
                true
            )


        if not prompt then

            debugPrint(
                "Serve",
                i,
                "has no ProximityPrompt -> skipping"
            )

            continue
        end


        debugPrint(
            "Found ProximityPrompt for Serve",
            i
        )


        --------------------------------------------------
        -- Pathfind
        --------------------------------------------------

        local reached =
            walkToPart(servePart)


        if not reached then

            debugPrint(
                "Could not reach Serve",
                i,
                "-> skipping"
            )

            continue
        end


        --------------------------------------------------
        -- Fire prompt
        --------------------------------------------------

        debugPrint(
            "Firing prompt for Serve",
            i
        )


        fireproximityprompt(prompt)


        debugPrint(
            "Serve",
            i,
            "completed"
        )


        task.wait(0.2)
    end


    debugPrint(
        "========== SERVE ITERATION COMPLETE =========="
    )
end


--------------------------------------------------
-- Auto Assign
--------------------------------------------------

mainTab:Toggle({
    Title = "Auto Assign",
    Value = false,

    Callback = function(state)

        toggles.autoAssign = state

        debugPrint(
            "Auto Assign:",
            state
        )


        if not state then

            debugPrint(
                "Auto Assign disabled"
            )

            return
        end


        debugPrint(
            "Auto Assign enabled"
        )


        while toggles.autoAssign do

            debugPrint(
                "----- New assignment attempt -----"
            )


            --------------------------------------------------
            -- Get NPC
            --------------------------------------------------

            local counterInfo =
                GetCounterInfo:InvokeServer()


            if not counterInfo then

                debugPrint(
                    "No counter info returned"
                )

                task.wait(1)
                continue
            end


            if not counterInfo.NpcId then

                debugPrint(
                    "CounterInfo has no NpcId"
                )

                task.wait(1)
                continue
            end


            local thisNpcId =
                counterInfo.NpcId


            debugPrint(
                "NPC ID:",
                thisNpcId
            )


            --------------------------------------------------
            -- Find available table
            --------------------------------------------------

            local thisLamesa
            local thisIndex


            for tableNumber = 1, 12 do

                if not toggles.autoAssign then
                    break
                end


                local tableName =
                    "Table" .. tableNumber


                local lamesa =
                    tables:FindFirstChild(
                        tableName
                    )


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
                -- CurrentTable
                --------------------------------------------------

                local currentTable =
                    lamesa:FindFirstChild(
                        "CurrentTable"
                    )


                if not currentTable then

                    debugPrint(
                        tableName,
                        "-> CurrentTable missing"
                    )

                    continue
                end


                if #currentTable:GetChildren() == 0 then

                    debugPrint(
                        tableName,
                        "-> CurrentTable EMPTY"
                    )

                    continue
                end


                debugPrint(
                    tableName,
                    "-> CurrentTable occupied"
                )


                --------------------------------------------------
                -- CurrentChair
                --------------------------------------------------

                local currentChair =
                    lamesa:FindFirstChild(
                        "CurrentChair"
                    )


                if not currentChair then

                    debugPrint(
                        tableName,
                        "-> CurrentChair missing"
                    )

                    continue
                end


                --------------------------------------------------
                -- Chair 1
                --------------------------------------------------

                local placedChair1 =
                    currentChair:FindFirstChild(
                        "PlacedChair1"
                    )


                if placedChair1 then

                    local occupiedBy1 =
                        lamesa:GetAttribute(
                            "OccupiedBy1"
                        )


                    debugPrint(
                        tableName,
                        "-> PlacedChair1 | OccupiedBy1:",
                        occupiedBy1
                    )


                    if not occupiedBy1 then

                        thisLamesa = lamesa
                        thisIndex = 1

                        debugPrint(
                            "FOUND:",
                            tableName,
                            "Seat 1"
                        )

                        break
                    end
                end


                --------------------------------------------------
                -- Chair 2
                --------------------------------------------------

                local placedChair2 =
                    currentChair:FindFirstChild(
                        "PlacedChair2"
                    )


                if placedChair2 then

                    local occupiedBy2 =
                        lamesa:GetAttribute(
                            "OccupiedBy2"
                        )


                    debugPrint(
                        tableName,
                        "-> PlacedChair2 | OccupiedBy2:",
                        occupiedBy2
                    )


                    if not occupiedBy2 then

                        thisLamesa = lamesa
                        thisIndex = 2

                        debugPrint(
                            "FOUND:",
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
            -- No table
            --------------------------------------------------

            if not thisLamesa then

                debugPrint(
                    "No available table/seat"
                )

                task.wait(1)
                continue
            end


            --------------------------------------------------
            -- Assign
            --------------------------------------------------

            debugPrint(
                "Assigning NPC:",
                thisNpcId,
                "Table:",
                thisLamesa.Name,
                "Seat:",
                thisIndex
            )


            AssignNPC:FireServer({
                NpcId = thisNpcId,
                Seat = thisIndex,
                NPCName = thisNpcId,
                Slot = thisLamesa
            })


            debugPrint(
                "AssignNPC fired"
            )


            task.wait(1)
        end


        debugPrint(
            "Auto Assign loop stopped"
        )
    end
})


--------------------------------------------------
-- Auto Serve Toggle
--------------------------------------------------

mainTab:Toggle({
    Title = "Auto Serve",
    Value = false,

    Callback = function(state)

        toggles.autoServe = state

        debugPrint(
            "Auto Serve:",
            state
        )


        if not state then

            debugPrint(
                "Auto Serve disabled"
            )

            return
        end


        debugPrint(
            "Auto Serve enabled"
        )


        while toggles.autoServe do

            serveIteration()

            if toggles.autoServe then
                task.wait(1)
            end

        end


        debugPrint(
            "Auto Serve loop stopped"
        )
    end
})