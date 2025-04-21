-- Rylq's Admin Panel v1 with Command Bar

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")
local flying = false
local height = 0
local speed = 50
local moveDirection = Vector3.zero
local bodyGyro, bodyVelocity
local noclipOn = false
local espOn = false

-- Notification Utility
local function notify(msg)
    StarterGui:SetCore("SendNotification", {
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
    Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 9e4
    bodyGyro.CFrame = Camera.CFrame
    bodyGyro.Parent = Character.HumanoidRootPart

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = Character.HumanoidRootPart

    RunService.RenderStepped:Connect(function()
        if flying then
            bodyGyro.CFrame = Camera.CFrame
            local direction = moveDirection.Unit * speed
            if moveDirection.Magnitude == 0 then direction = Vector3.zero end
            bodyVelocity.Velocity = direction + Vector3.new(0, height, 0)
        else
            if bodyGyro then bodyGyro:Destroy() end
            if bodyVelocity then bodyVelocity:Destroy() end
        end
    end)
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.Space then
        height = 50
    elseif key == Enum.KeyCode.LeftShift then
        height = -50
    elseif key == Enum.KeyCode.W then
        moveDirection = moveDirection + Camera.CFrame.LookVector
    elseif key == Enum.KeyCode.S then
        moveDirection = moveDirection - Camera.CFrame.LookVector
    elseif key == Enum.KeyCode.A then
        moveDirection = moveDirection - Camera.CFrame.RightVector
    elseif key == Enum.KeyCode.D then
        moveDirection = moveDirection + Camera.CFrame.RightVector
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local key = input.KeyCode
    if key == Enum.KeyCode.Space or key == Enum.KeyCode.LeftShift then
        height = 0
    elseif key == Enum.KeyCode.W or key == Enum.KeyCode.S or key == Enum.KeyCode.A or key == Enum.KeyCode.D then
        moveDirection = Vector3.zero
    end
end)

-- ESP toggle stub
local function toggleESP()
    espOn = not espOn
    notify("ESP is now " .. (espOn and "ON" or "OFF"))
end

-- Command parser
local function parseCommand(msg)
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
        notify("Command list: :fly, :nofly, :speed <num>, :jumppower <num>, :noclip, :clip, :re, :fov <num>, :esp, :reset, :cmds")
    end
end

LocalPlayer.Chatted:Connect(parseCommand)

-- Command bar GUI
local function createCommandBar()
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "CommandBarGui"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0.4, 0, 0, 40)
    frame.Position = UDim2.new(0.3, 0, 1, -60)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.Visible = false
    frame.BorderSizePixel = 0

    local inputBox = Instance.new("TextBox", frame)
    inputBox.Size = UDim2.new(1, -10, 1, -10)
    inputBox.Position = UDim2.new(0, 5, 0, 5)
    inputBox.BackgroundTransparency = 0.2
    inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    inputBox.TextColor3 = Color3.new(1, 1, 1)
    inputBox.PlaceholderText = "Enter command..."
    inputBox.ClearTextOnFocus = false
    inputBox.Font = Enum.Font.SourceSans
    inputBox.TextSize = 20
    inputBox.TextXAlignment = Enum.TextXAlignment.Left

    local history = {}
    local historyIndex = 0

    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local text = inputBox.Text
            if text ~= "" then
                table.insert(history, text)
                historyIndex = #history + 1
                parseCommand(text)
                inputBox.Text = ""
                frame.Visible = false
            end
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Semicolon then
            frame.Visible = not frame.Visible
            if frame.Visible then
                inputBox:CaptureFocus()
            end
        elseif frame.Visible then
            if input.KeyCode == Enum.KeyCode.Up then
                historyIndex = math.clamp(historyIndex - 1, 1, #history)
                inputBox.Text = history[historyIndex] or ""
            elseif input.KeyCode == Enum.KeyCode.Down then
                historyIndex = math.clamp(historyIndex + 1, 1, #history)
                inputBox.Text = history[historyIndex] or ""
            end
        end
    end)
end

createCommandBar()
notify("Rylq's Admin Panel v1 Loaded. Press ';' to open the command bar or type ':cmds' for help.")
