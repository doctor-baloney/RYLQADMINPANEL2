local Players, UIS, TweenService = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("TweenService")
local lp = Players.LocalPlayer
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name, gui.ResetOnSpawn = "RYLQAdminPanel", false

local function createUICorner(parent, rad) local c = Instance.new("UICorner", parent) c.CornerRadius = UDim.new(0, rad or 10) end

local frame = Instance.new("Frame", gui)
frame.Size, frame.Position, frame.BackgroundColor3, frame.Active, frame.Draggable = UDim2.fromOffset(320, 460), UDim2.new(0, 50, 0.5, -230), Color3.new(), true, true

local title = Instance.new("TextLabel", frame)
title.Size, title.Text, title.TextColor3, title.Font, title.TextSize, title.BackgroundColor3 = UDim2.new(1, 0, 0, 40), "RYLQ'S ADMIN PANEL", Color3.new(1,1,1), Enum.Font.Legacy, 20, Color3.fromRGB(30,30,30)

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size, scroll.Position, scroll.CanvasSize, scroll.ScrollBarThickness, scroll.BackgroundTransparency = UDim2.new(1, 0, 1, -100), UDim2.new(0, 0, 0, 40), UDim2.new(), 6, 1
local layout = Instance.new("UIListLayout", scroll)
layout.Padding, layout.SortOrder = UDim.new(0, 4), Enum.SortOrder.LayoutOrder

local commands = {
	["Speed"] = function(v) lp.Character.Humanoid.WalkSpeed = tonumber(v) or 50 end,
	["JumpPower"] = function(v) lp.Character.Humanoid.JumpPower = tonumber(v) or 150 end,
	["Reset Speed"] = function() lp.Character.Humanoid.WalkSpeed = 16 end,
	["Reset Jump"] = function() lp.Character.Humanoid.JumpPower = 50 end,
	["Fly"] = function()
		local mouse = lp:GetMouse()
		local torso = lp.Character:WaitForChild("HumanoidRootPart")
		local flying = false
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local speed = 0
		local maxspeed = 50

		local function Fly()
			local bg = Instance.new("BodyGyro", torso)
			bg.P = 9e4
			bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
			bg.cframe = torso.CFrame
			local bv = Instance.new("BodyVelocity", torso)
			bv.velocity = Vector3.new(0,0.1,0)
			bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
			repeat
				wait()
				lp.Character.Humanoid.PlatformStand = true
				if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
					speed = speed + 0.5 + (speed / maxspeed)
					if speed > maxspeed then speed = maxspeed end
				elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
					speed = speed - 1
					if speed < 0 then speed = 0 end
				end
				if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
					bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f + ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p)) * speed
				elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
					bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f + ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p)) * speed
				else
					bv.velocity = Vector3.new(0, 0.1, 0)
				end
				bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / maxspeed), 0, 0)
			until not flying
			ctrl = {f = 0, b = 0, l = 0, r = 0}
			speed = 0
			bg:Destroy()
			bv:Destroy()
			lp.Character.Humanoid.PlatformStand = false
		end

		mouse.KeyDown:connect(function(key)
			if key:lower() == "e" then
				flying = not flying
				if flying then
					Fly()
				end
			elseif key:lower() == "w" then
				ctrl.f = 1
			elseif key:lower() == "s" then
				ctrl.b = -1
			elseif key:lower() == "a" then
				ctrl.l = -1
			elseif key:lower() == "d" then
				ctrl.r = 1
			end
		end)

		mouse.KeyUp:connect(function(key)
			if key:lower() == "w" then
				ctrl.f = 0
			elseif key:lower() == "s" then
				ctrl.b = 0
			elseif key:lower() == "a" then
				ctrl.l = 0
			elseif key:lower() == "d" then
				ctrl.r = 0
			end
		end)

		if flying then
			Fly()
		end
	end
}

for name, func in pairs(commands) do
	local btn = Instance.new("TextButton", scroll)
	btn.Size, btn.Text, btn.TextColor3, btn.Font, btn.TextSize = UDim2.new(1, -10, 0, 40), name, Color3.new(1,1,1), Enum.Font.Legacy, 18
	btn.Position, btn.BackgroundColor3, btn.AutoButtonColor = UDim2.new(0, 5, 0, 0), Color3.fromRGB(200,0,0), false
	createUICorner(btn)

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 30, 30)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 0, 0)}):Play()
	end)
	btn.MouseButton1Click:Connect(function() pcall(func) end)
end

scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end)

local input = Instance.new("TextBox", frame)
input.Size, input.Position, input.PlaceholderText = UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 1, -50), ":speed 100"
input.Font, input.TextSize, input.TextColor3, input.BackgroundColor3 = Enum.Font.Legacy, 18, Color3.new(1,1,1), Color3.fromRGB(20, 20, 20)
input.BorderSizePixel, input.ClearTextOnFocus = 0, false
createUICorner(input, 8)

input.FocusLost:Connect(function(enter)
	if enter then
		local args = input.Text:split(" ")
		local cmd, val = args[1]:gsub(":", ""):lower(), args[2]
		for k, f in pairs(commands) do
			if cmd == k:lower():gsub(" ", "") then
				pcall(f, val)
			end
		end
		input.Text = ""
	end
end)

UIS.InputBegan:Connect(function(i, g)
	if not g and i.KeyCode == Enum.KeyCode.F then
		frame.Visible = not frame.Visible
	end
end)
