local Players, UIS, TweenService = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("TweenService")
local lp = Players.LocalPlayer
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name, gui.ResetOnSpawn = "RYLQAdminPanel", false

local function createUICorner(parent, rad) 
    local c = Instance.new("UICorner", parent) 
    c.CornerRadius = UDim.new(0, rad or 10) 
end

-- Create the frame for the Admin Panel GUI
local frame = Instance.new("Frame", gui)
frame.Size, frame.Position, frame.BackgroundColor3, frame.Active, frame.Draggable = UDim2.fromOffset(320, 460), UDim2.new(0, 50, 0.5, -230), Color3.new(), true, true

-- Title for the Admin Panel
local title = Instance.new("TextLabel", frame)
title.Size, title.Text, title.TextColor3, title.Font, title.TextSize, title.BackgroundColor3 = UDim2.new(1, 0, 0, 40), "RYLQ'S ADMIN PANEL", Color3.new(1, 1, 1), Enum.Font.Legacy, 20, Color3.fromRGB(30,30,30)

-- Scrolling frame for commands
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size, scroll.Position, scroll.CanvasSize, scroll.ScrollBarThickness, scroll.BackgroundTransparency = UDim2.new(1, 0, 1, -100), UDim2.new(0, 0, 0, 40), UDim2.new(), 6, 1
local layout = Instance.new("UIListLayout", scroll)
layout.Padding, layout.SortOrder = UDim.new(0, 4), Enum.SortOrder.LayoutOrder

-- Command functions
local commands = {
    ["Speed"] = function(v) 
        lp.Character.Humanoid.WalkSpeed = tonumber(v) or 50 
    end,
    ["JumpPower"] = function(v) 
        lp.Character.Humanoid.JumpPower = tonumber(v) or 150 
    end,
    ["Reset Speed"] = function() 
        lp.Character.Humanoid.WalkSpeed = 16 
    end,
    ["Reset Jump"] = function() 
        lp.Character.Humanoid.JumpPower = 50 
    end,
    ["Fly (Simple)"] = function() 
        local bv = Instance.new("BodyVelocity", lp.Character.HumanoidRootPart)
        bv.Velocity, bv.MaxForce = Vector3.new(0, 50, 0), Vector3.new(0, math.huge, 0)
        game.Debris:AddItem(bv, 2)
    end
}

-- Create buttons for each command
for name, func in pairs(commands) do
    local btn = Instance.new("TextButton", scroll)
    btn.Size, btn.Text, btn.TextColor3, btn.Font, btn.TextSize = UDim2.new(1, -10, 0, 40), name, Color3.new(1, 1, 1), Enum.Font.Legacy, 18
    btn.Position, btn.BackgroundColor3, btn.AutoButtonColor = UDim2.new(0, 5, 0, 0), Color3.fromRGB(200,0,0), false
    createUICorner(btn)

    -- Button hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 30, 30)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 0, 0)}):Play()
    end)

    -- Button functionality when clicked
    btn.MouseButton1Click:Connect(function() pcall(func) end)
end

-- Update the scrolling frame size when content changes
scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end)

-- TextBox for typing commands (with : prefix)
local input = Instance.new("TextBox", frame)
input.Size, input.Position, input.PlaceholderText = UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 1, -50), "Type command (e.g. :speed 100)"
input.Font, input.TextSize, input.TextColor3, input.BackgroundColor3 = Enum.Font.Legacy, 18, Color3.new(1, 1, 1), Color3.fromRGB(20, 20, 20)
input.BorderSizePixel, input.ClearTextOnFocus = 0, false
createUICorner(input, 8)

-- Handle command input
input.FocusLost:Connect(function(enter)
    if not enter then return end
    local args = input.Text:split(" ")
    local cmd, val = args[1]:gsub(":", ""):lower(), args[2]
    for k, f in pairs(commands) do
        if cmd == k:lower():gsub(" ", "") then
            pcall(f, val)
        end
    end
    input.Text = ""
end)

-- Toggle visibility of the frame using the "F" key
UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.F then
        frame.Visible = not frame.Visible
    end
end)
