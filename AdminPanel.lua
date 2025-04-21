-- Rylqs Admin Panel

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

-- Command system
local flyOn = false
local noclipOn = false
local espOn = false

-- Notification Utility
local function notify(msg)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Rylqs Admin Panel",
        Text = msg,
        Duration = 3
    })
end

-- FLY
local function fly()
    flyOn = true
    local bodyGyro = Instance.new("BodyGyro", Character.HumanoidRootPart)
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = workspace.CurrentCamera.CFrame

    local bodyVel = Instance.new("BodyVelocity", Character.HumanoidRootPart)
    bodyVel.Velocity = Vector3.new(0, 0, 0)
    bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    notify("Fly enabled. Use WASD.")

    RunService.RenderStepped:Connect(function()
        if flyOn then
            bodyGyro.CFrame = workspace.CurrentCamera.CFrame
            bodyVel.Velocity = workspace.CurrentCamera.CFrame.LookVector * 50
        else
            bodyGyro:Destroy()
            bodyVel:Destroy()
        end
    end)
end

-- NOCLIP
RunService.Stepped:Connect(function()
    if noclipOn and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

-- ESP
local function toggleESP()
    espOn = not espOn
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char and char:FindFirstChild("Head") then
                if espOn then
                    local billboard = Instance.new("BillboardGui", char.Head)
                    billboard.Name = "ESP"
                    billboard.Size = UDim2.new(0, 100, 0, 40)
                    billboard.AlwaysOnTop = true
                    local label = Instance.new("TextLabel", billboard)
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = plr.Name
                    label.TextColor3 = Color3.new(1, 0, 0)
                else
                    if char.Head:FindFirstChild("ESP") then
                        char.Head.ESP:Destroy()
                    end
                end
            end
        end
    end
    notify("ESP " .. (espOn and "ON" or "OFF"))
end
-- VEHICLE FLY
local vflyActive = false
local vflyBodyGyro, vflyBodyVel

local function vehicleFly()
    if vflyActive then
        vflyActive = false
        if vflyBodyGyro then vflyBodyGyro:Destroy() end
        if vflyBodyVel then vflyBodyVel:Destroy() end
        notify("Vehicle Fly OFF")
        return
    end

    local seat = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Seat", true)
    if not seat or not seat:IsA("Seat") or not seat.Occupant then
        notify("You must be sitting in a vehicle seat.")
        return
    end

    local vehicle = seat:FindFirstAncestorWhichIsA("Model")
    if not vehicle then
        notify("Couldn't find vehicle model.")
        return
    end

    local root = vehicle:FindFirstChild("PrimaryPart") or seat
    if not root then
        notify("No valid root part for vehicle.")
        return
    end

    vflyActive = true
    notify("Vehicle Fly ON. Use WASD + Q/E")

    vflyBodyGyro = Instance.new("BodyGyro", root)
    vflyBodyGyro.P = 9e4
    vflyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    vflyBodyGyro.CFrame = workspace.CurrentCamera.CFrame

    vflyBodyVel = Instance.new("BodyVelocity", root)
    vflyBodyVel.Velocity = Vector3.new(0, 0, 0)
    vflyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    local uis = game:GetService("UserInputService")
    local moveDir = Vector3.zero

    uis.InputBegan:Connect(function(input)
        if not vflyActive then return end
        local key = input.KeyCode
        if key == Enum.KeyCode.W then moveDir = moveDir + Vector3.new(0, 0, -1) end
        if key == Enum.KeyCode.S then moveDir = moveDir + Vector3.new(0, 0, 1) end
        if key == Enum.KeyCode.A then moveDir = moveDir + Vector3.new(-1, 0, 0) end
        if key == Enum.KeyCode.D then moveDir = moveDir + Vector3.new(1, 0, 0) end
        if key == Enum.KeyCode.E then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if key == Enum.KeyCode.Q then moveDir = moveDir + Vector3.new(0, -1, 0) end
    end)

    uis.InputEnded:Connect(function(input)
        local key = input.KeyCode
        if key == Enum.KeyCode.W then moveDir = moveDir
-- Command Parser
LocalPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()
    if msg == ":fly" then
        fly()
    elseif msg == ":nofly" then
        flyOn = false
        notify("Fly disabled.")
    elseif msg:match(":speed") then
        local spd = tonumber(msg:split(" ")[2]) or 100
        Humanoid.WalkSpeed = spd
        notify("Speed set to " .. spd)
    elseif msg:match(":jumppower") then
        local jp = tonumber(msg:split(" ")[2]) or 100
        Humanoid.JumpPower = jp
        notify("JumpPower set to " .. jp)
    elseif msg == ":noclip" then
        noclipOn = true
        notify("Noclip ON")
    elseif msg == ":clip" then
        noclipOn = false
        notify("Noclip OFF")
    elseif msg == ":re" then
        LocalPlayer:LoadCharacter()
        notify("Respawned.")
    elseif msg:match(":fov") then
        local fov = tonumber(msg:split(" ")[2]) or 70
        Camera.FieldOfView = fov
        notify("FOV set to " .. fov)
    elseif msg == ":esp" then
        toggleESP()
    elseif msg == ":reset" then
        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50
        Camera.FieldOfView = 70
        flyOn = false
        noclipOn = false
        notify("Reset all effects.")
    end
end)

notify("Rylqs Admin Panel Loaded. Type commands in chat.")
