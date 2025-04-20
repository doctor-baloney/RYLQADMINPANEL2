-- Services
local lp = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name, gui.ResetOnSpawn = "RYLQAdminPanel", false

-- Admin check (add your username here)
local admins = {"YourUsername"}  -- Replace with your Roblox username or multiple admins
if not table.find(admins, lp.Name) then
    return -- If not an admin, stop the script
end

-- Sound effect setup
local sound = Instance.new("Sound", lp.Character)
sound.SoundId = "rbxassetid://183681313" -- Add any sound asset ID you want

-- Main panel frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(320, 460)
frame.Position = UDim2.new(0, 50, 0.5, -230)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.Active = true
frame.Draggable = true

-- Title of the panel
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "RYLQ'S ADMIN PANEL"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.Legacy
title.TextSize = 20
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

-- Toggle button
local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(0, 100, 0, 40)
toggleButton.Text = "Toggle"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.Legacy
toggleButton.TextSize = 18
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
toggleButton.Position = UDim2.new(0, 5, 0, 40)

local toggle = false
toggleButton.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- Scroll frame for commands
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, 0, 1, -100)
scroll.Position = UDim2.new(0, 0, 0, 80)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Commands table
local commands = {
    ["Speed"] = function(v) 
        lp.Character.Humanoid.WalkSpeed = tonumber(v) or 50
        sound:Play()
    end,
    ["JumpPower"] = function(v) 
        lp.Character.Humanoid.JumpPower = tonumber(v) or 150
        sound:Play()
    end,
    ["Reset Speed"] = function() 
        lp.Character.Humanoid.WalkSpeed = 16
        sound:Play()
    end,
    ["Reset Jump"] = function() 
        lp.Character.Humanoid.JumpPower = 50
        sound:Play()
    end,
    ["Fly"] = function() 
        local bv = Instance.new("BodyVelocity", lp.Character.HumanoidRootPart)
        bv.Velocity = Vector3.new(0, 50, 0)
        bv.MaxForce = Vector3.new(0, math.huge, 0)
        game.Debris:AddItem(bv, 2)
        sound:Play()
    end
}

-- Create command buttons
for name, func in pairs(commands) do
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Legacy
    btn.TextSize = 18
    btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.AutoButtonColor = false
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 10)
    
    -- Button animations
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 30, 30)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 0, 0)}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        pcall(func)
    end)
end

-- Adjust scroll size dynamically
scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end)

-- Input box for commands
local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(1, -20, 0, 40)
input.Position = UDim2.new(0, 10, 1, -50)
input.PlaceholderText = ":speed 100"
input.Font = Enum.Font.Legacy
input.TextSize = 18
input.TextColor3 = Color3.new(1, 1, 1)
input.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
input.BorderSizePixel = 0
local corner = Instance.new("UICorner", input)
corner.CornerRadius = UDim.new(0, 8)

-- Clear button for input box
local clearButton = Instance.new("TextButton", frame)
clearButton.Size = UDim2.new(0, 100, 0, 40)
clearButton.Text = "Clear"
clearButton.TextColor3 = Color3.new(1, 1, 1)
clearButton.Font = Enum.Font.Legacy
clearButton.TextSize = 18
clearButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
clearButton.Position = UDim2.new(0, 5, 0, 80)
clearButton.MouseButton1Click:Connect(function()
    input.Text = ""
end)

-- Command input handling
input.FocusLost:Connect(function(enter)
    if enter then
        local args = input.Text:split(" ")
        local cmd, val = args[1]:gsub(":", ""):lower(), args[2]
        for k, f in pairs(commands) do
            if cmd == k:lower():gsub(" ", "") then
                pcall(f, val)
            else
                print("Error: Command not found.")
            end
        end
        input.Text = ""
    end
end)

-- Toggle the visibility of the admin panel with the F key
UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.F then
        frame.Visible = not frame.Visible
    end
end)
