-- Rylq's Admin Panel v1 (Upgraded Fly System)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local flying = false
local flyConn
local flyDirection = Vector3.zero
local flyVertical = 0
local speed = 50

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
    return getCharacter():WaitForChild("Humanoid")
end

local function notify(msg)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Rylq's Admin Panel",
            Text = msg,
            Duration = 3
        })
    end)
end

-- GUI for :cmds
local function createCmdsGUI()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "CmdsGui"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 400, 0, 300)
    frame.Position = UDim2.new(0.5, -200, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.3

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "Commands"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundTransparency = 1
    title.TextSize = 24

    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, 0, 1, -30)
    scroll.Position = UDim2.new(0, 0, 0, 30)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.CanvasSize = UDim2.new(0, 0, 0, 500)

    local commands = {
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

    for i, cmd in ipairs(commands) do
        local lbl = Instance.new("TextLabel", scroll)
        lbl.Size = UDim2.new(1, -10, 0, 30)
        lbl.Position = UDim2.new(0, 5, 0, (i - 1) * 32)
        lbl.Text = cmd
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.BackgroundTransparency = 1
        lbl.TextSize = 18
        lbl.TextXAlignment = Enum.TextXAlignment.Left
    end

    local close = Instance.new("TextButton", frame)
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -35, 0, 0)
    close.Text = "X"
    close.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    close.TextColor3 = Color3.new(1, 1, 1)
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
end

-- Fly logic
local function startFlying()
    if flying then return end
    flying = true

    local char = getCharacter()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local gyro = Instance.new("BodyGyro", hrp)
    gyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    gyro.P = 1e5
    gyro.D = 500
    gyro.CFrame = hrp.CFrame

    local vel = Instance.new("BodyVelocity", hrp)
    vel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    vel.Velocity = Vector3.zero

    notify("Flying enabled. Use WASD + Space/Shift")

    flyConn = RunService.RenderStepped:Connect(function()
        gyro.CFrame = Camera.CFrame

        local move = flyDirection.Unit * speed
        if flyDirection == Vector3.zero then
            move = Vector3.zero
        end

        vel.Velocity = move + Vector3.new(0, flyVertical, 0)
    end)

    -- Clear on character death
    char:WaitForChild("Humanoid").Died:Connect(function()
        flying = false
        if flyConn then flyConn:Disconnect() end
        gyro:Destroy()
        vel:Destroy()
    end)
end

local function stopFlying()
    if not flying then return end
    flying = false
    if flyConn then flyConn:Disconnect() end

    local hrp = getCharacter():FindFirstChild("HumanoidRootPart")
    if hrp then
        if hrp:FindFirstChildOfClass("BodyGyro") then
            hrp:FindFirstChildOfClass("BodyGyro"):Destroy()
        end
        if hrp:FindFirstChildOfClass("BodyVelocity") then
            hrp:FindFirstChildOfClass("BodyVelocity"):Destroy()
        end
    end

    notify("Flying disabled.")
end

-- Input tracking for fly movement
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode
        if key == Enum.KeyCode.Space then
            flyVertical = 50
        elseif key == Enum.KeyCode.LeftShift then
            flyVertical = -50
        elseif key == Enum.KeyCode.W then
            flyDirection = flyDirection + Camera.CFrame.LookVector
        elseif key == Enum.KeyCode.S then
            flyDirection = flyDirection - Camera.CFrame.LookVector
        elseif key == Enum.KeyCode.A then
            flyDirection = flyDirection - Camera.CFrame.RightVector
        elseif key == Enum.KeyCode.D then
            flyDirection = flyDirection + Camera.CFrame.RightVector
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode
        if key == Enum.KeyCode.Space or key == Enum.KeyCode.LeftShift then
            flyVertical = 0
        elseif key == Enum.KeyCode.W or key == Enum.KeyCode.S or key == Enum.KeyCode.A or key == Enum.KeyCode.D then
            flyDirection = Vector3.zero
        end
    end
end)

-- Command handler
local noclip = false
local espEnabled = false -- placeholder

LocalPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()
    local char = getCharacter()
    local humanoid = getHumanoid()

    if msg == ":fly" then
        startFlying()
    elseif msg == ":nofly" then
        stopFlying()
    elseif msg:match("^:speed") then
        local value = tonumber(msg:split(" ")[2]) or 100
        humanoid.WalkSpeed = value
        notify("Speed set to " .. value)
    elseif msg:match("^:jumppower") then
        local value = tonumber(msg:split(" ")[2]) or 100
        humanoid.JumpPower = value
        notify("JumpPower set to " .. value)
    elseif msg == ":noclip" then
        noclip = true
        notify("Noclip ON")
    elseif msg == ":clip" then
        noclip = false
        notify("Noclip OFF")
    elseif msg == ":re" then
        LocalPlayer:LoadCharacter()
        notify("Respawned.")
    elseif msg:match("^:fov") then
        local value = tonumber(msg:split(" ")[2]) or 70
        Camera.FieldOfView = value
        notify("FOV set to " .. value)
    elseif msg == ":esp" then
        espEnabled = not espEnabled
        notify("ESP toggled: " .. tostring(espEnabled))
    elseif msg == ":reset" then
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        Camera.FieldOfView = 70
        stopFlying()
        noclip = false
        notify("All settings reset.")
    elseif msg == ":cmds" then
        createCmdsGUI()
    end
end)

notify("Rylq's Admin Panel v1 Loaded — Type ':cmds' for commands.")
