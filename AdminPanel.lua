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

-- Create the :cmds GUI
local function createCmdsGUI()
    -- Create a ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CmdsGui"
    screenGui.Parent = game.CoreGui

    -- Create a frame for the command list
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 300)  -- Adjust the size as needed
    frame.Position = UDim2.new(0.5, -200, 0.5, -150)  -- Center the frame
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.5
    frame.Parent = screenGui

    -- Add a title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "Commands"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 24
    titleLabel.Parent = frame

    -- Create a scrolling frame for the command list
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 0.8, -30)  -- Adjust the size to fit under the title
    scrollFrame.Position = UDim2.new(0, 0, 0, 30)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)  -- Adjust the canvas size as needed
    scrollFrame.ScrollBarThickness = 10
    scrollFrame.Parent = frame

    -- Create a TextLabel for each command
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

    -- Create a close button with a red X
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 0)  -- Top-right corner
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 20
    closeButton.Parent = frame

    -- Close the GUI when the close button is clicked
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- FLY
local function startFlying()
    if flying then return end
    flying = true
    notify("Flying enabled. Use WASD to move, Space to rise, Shift to descend.")

    -- Disable humanoid animations while flying
    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    -- Creating BodyGyro for smooth rotation
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.D = 1000 -- Reduced D for smoother rotation
    bodyGyro.P = 10000 -- Increased P for quicker stabilization
    bodyGyro.CFrame = Camera.CFrame
    bodyGyro.Parent = Character.HumanoidRootPart

    -- Creating BodyVelocity for smooth movement
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = Character.HumanoidRootPart

    -- Fly loop with smoother control
    RunService.RenderStepped:Connect(function(_, dt)
        if flying then
            -- Get the direction the camera is facing
            local forward = Camera.CFrame.LookVector
            local right = Camera.CFrame.RightVector
            local up = Camera.CFrame.UpVector

            -- Update movement based on key inputs (WASD)
            bodyGyro.CFrame = Camera.CFrame -- Keep the character facing the camera direction
            bodyVelocity.Velocity = (moveDirection * speed) + Vector3.new(0, height, 0) -- Apply smooth movement and height

            -- Smooth movement adjustment over time
            bodyVelocity.Velocity = bodyVelocity.Velocity:Lerp(bodyVelocity.Velocity, 0.2) -- Lerp for smoother transitions
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
            -- Ensure proper movement directions
            moveDirection = moveDirection - Camera.CFrame.RightVector -- Stop movement in that direction
        end
    end
end)

-- Command Parser
LocalPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()
    if msg == ":fly" then
        startFlying()
    elseif msg == ":nofly" then
        flying = false
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)  -- Restore normal animation state
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
        createCmdsGUI()
    end
end)

-- Add command bar opening functionality
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Semicolon then
        createCmdsGUI()
    end
end)

notify("Rylq's Admin Panel v1 Loaded. Type ':cmds' for a list of commands.")
