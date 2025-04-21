-- Rylq's Admin Panel v1

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local flying = false
local height = 0
local speed = 50
local moveDirection = Vector3.zero
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

-- FLY
local function startFlying()
    if flying then return end
    flying = true
    notify("Flying enabled. Use WASD to move, Space to rise, Shift to descend.")

    -- Creating BodyGyro for rotation to follow the camera
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.D = 9e3
    bodyGyro.P = 9e4
    bodyGyro.CFrame = Camera.CFrame
    bodyGyro.Parent = Character.HumanoidRootPart

    -- Creating BodyVelocity for movement
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = Character.HumanoidRootPart

    -- Fly loop
    RunService.RenderStepped:Connect(function(_, dt)
        if flying then
            -- Get the direction the camera is facing
            local forward = Camera.CFrame.LookVector
            local right = Camera.CFrame.RightVector
            local up = Camera.CFrame.UpVector

            -- Apply the movement in sync with camera direction
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
        toggleESP()
    elseif msg == ":reset" then
        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50
        Camera.FieldOfView = 70
        flying = false
        noclipOn = false
        notify("Reset all effects.")
    elseif msg == ":cmds" then
        notify("Commands: :fly, :nofly, :speed <value>, :jumppower <value>, :noclip, :clip, :re, :fov <value>, :esp, :reset, :cmds")
    end
end)

notify("Rylq's Admin Panel v1 Loaded. Type ':cmds' for a list of commands.")
