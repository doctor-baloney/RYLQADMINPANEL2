-- Rylq's Admin Panel v1

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

local flying = false
local speed = 50
local height = 0
local moveDirection = Vector3.zero

-- Body Parts
local bodyGyro, bodyVelocity

-- Command list
local commands = {
    ":fly - Toggle flying",
    ":nofly - Disable flying",
    ":speed <value> - Set your walking speed",
    ":jumppower <value> - Set your jump power",
    ":noclip - Toggle noclip mode",
    ":clip - Disable noclip mode",
    ":re - Respawn your character",
    ":fov <value> - Set field of view",
    ":esp - Toggle ESP",
    ":reset - Reset all settings",
    ":cmds - Show this command list"
}

-- Notification Utility
local function notify(msg)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Rylq's Admin v1",
        Text = msg,
        Duration = 3
    })
end

-- Function to start flying (Kohl's Admin Style)
local function startFlying()
    if flying then return end
    flying = true
    notify("Flying enabled. Use WASD to move, Space to rise, Shift to descend.")

    -- Creating BodyGyro for rotation
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.CFrame = Camera.CFrame
    bodyGyro.D = 9e3
    bodyGyro.P = 9e4
    bodyGyro.Parent = Character.HumanoidRootPart

    -- Creating BodyVelocity for movement
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = Character.HumanoidRootPart

    -- Fly loop
    RunService.RenderStepped:Connect(function(_, dt)
        if flying then
            -- Update velocity based on camera direction
            local forward = Camera.CFrame.LookVector
            local right = Camera.CFrame.RightVector
            local up = Camera.CFrame.UpVector

            bodyGyro.CFrame = Camera.CFrame -- Keep the character facing the camera direction
            bodyVelocity.Velocity = (moveDirection * speed) + (Vector3.new(0, height, 0)) -- Apply movement and height

            -- Smooth movement based on time
            bodyVelocity.Velocity = bodyVelocity.Velocity * dt
        else
            bodyGyro:Destroy()
            bodyVelocity:Destroy()
        end
    end)
end

-- Function to stop flying
local function stopFlying()
    if not flying then return end
    flying = false
    notify("Flying disabled.")
    bodyGyro:Destroy()
    bodyVelocity:Destroy()
end

-- Handle user input for flying controls
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode

        if key == Enum.KeyCode.Space then
            height = 10  -- Rising speed
        elseif key == Enum.KeyCode.LeftShift then
            height = -10 -- Descending speed
        elseif key == Enum.KeyCode.W then
            moveDirection = moveDirection + Camera.CFrame.LookVector
        elseif key == Enum.KeyCode.S then
            moveDirection = moveDirection - Camera.CFrame.LookVector
        elseif key == Enum.KeyCode.A then
            moveDirection = moveDirection - Camera.CFrame.RightVector
        elseif key == Enum.KeyCode.D then
            moveDirection = moveDirection + Camera.CFrame.RightVector
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode

        if key == Enum.KeyCode.Space or key == Enum.KeyCode.LeftShift then
            height = 0  -- Stop rising or descending
        elseif key == Enum.KeyCode.W or key == Enum.KeyCode.S or key == Enum.KeyCode.A or key == Enum.KeyCode.D then
            moveDirection = Vector3.zero -- Stop movement
        end
    end
end)

-- Command to toggle fly
local function toggleFly()
    if flying then
        stopFlying()
    else
        startFlying()
    end
end

-- Admin Panel Features
local flyOn = false
local noclipOn = false
local espOn = false

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

-- Command Parser
LocalPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()
    if msg == ":fly" then
        toggleFly()
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
    elseif msg == ":cmds" then
        -- Show the list of available commands
        local cmdList = table.concat(commands, "\n")
        notify("Available Commands:\n" .. cmdList)
    end
end)

notify("Rylq's Admin v1 loaded. Type ':cmds' for a list of commands.")
