-- Rylq's Admin Panel v1 (Updated Fly)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local flying = false
local speed = 50
local bodyGyro, bodyVelocity

-- Command system
local noclipOn = false
local espOn = false

-- Notification Utility
local function notify(msg)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Rylq's Admin Panel",
        Text = msg,
        Duration = 3
    })
end

-- Create the :cmds GUI
local function createCmdsGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CmdsGui"
    screenGui.Parent = game.CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 300)
    frame.Position = UDim2.new(0.5, -200, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.5
    frame.Parent = screenGui

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "Commands"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 24
    titleLabel.Parent = frame

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 0.8, -30)
    scrollFrame.Position = UDim2.new(0, 0, 0, 30)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
    scrollFrame.ScrollBarThickness = 10
    scrollFrame.Parent = frame

    local commandList = {
        ":fly - Enable flying",
        ":nofly - Disable flying",
        ":speed <value> - Set walking speed",
        ":jumppower <value> - Set jump power",
        ":noclip - Enable noclip mode",
        ":clip - Disable noclip mode",
        ":re - Respawn player",
        ":fov <value> - Set field of view",
        ":esp - Toggle ESP (highlight players)",
        ":reset - Reset all effects",
        ":cmds - Show this command list"
    }

    for _, cmd in ipairs(commandList) do
        local cmdLabel = Instance.new("TextLabel")
        cmdLabel.Text = cmd
        cmdLabel.Size = UDim2.new(1, 0, 0, 40)
        cmdLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        cmdLabel.BackgroundTransparency = 1
        cmdLabel.TextSize = 18
        cmdLabel.TextWrapped = true
        cmdLabel.Parent = scrollFrame
    end

    local closeButton = Instance.new("TextButton")
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 20
    closeButton.Parent = frame

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- Smooth Fly
local function startFlying()
    if flying then return end
    flying = true
    notify("Flying enabled. Use WASD to move, Space to rise, Shift to descend.")

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.D = 500
    bodyGyro.P = 3000
    bodyGyro.CFrame = Camera.CFrame
    bodyGyro.Parent = Character.HumanoidRootPart

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = Character.HumanoidRootPart

    RunService.RenderStepped:Connect(function()
        if not flying then
            if bodyGyro then bodyGyro:Destroy() end
            if bodyVelocity then bodyVelocity:Destroy() end
            return
        end

        local move = Vector3.zero
        local camCF = Camera.CFrame

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            move += camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            move -= camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            move -= camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            move += camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            move += camCF.UpVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            move -= camCF.UpVector
        end

        move = move.Unit * speed
        if move.Magnitude ~= move.Magnitude then move = Vector3.zero end -- NaN fix

        bodyGyro.CFrame = camCF
        bodyVelocity.Velocity = move
    end)
end

-- Command Parser
LocalPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()
    if msg == ":fly" then
        startFlying()
    elseif msg == ":nofly" then
        flying = false
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
        notify("ESP toggle not implemented in this version.")
    elseif msg == ":reset" then
        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50
        Camera.FieldOfView = 70
        flying = false
        noclipOn = false
        notify("Reset all effects.")
    elseif msg == ":cmds" then
        createCmdsGUI()
    end
end)

notify("Rylq's Admin Panel v1 Loaded. Type ':cmds' for a list of commands.")
