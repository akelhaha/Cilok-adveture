--// Utility
local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local function getCharParts()
    if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
        return plr.Character.Humanoid, plr.Character.HumanoidRootPart
    end
end

--// GUI Utama
local gui = Instance.new("ScreenGui", game.CoreGui)
local mainBtn = Instance.new("TextButton")
mainBtn.Size = UDim2.new(0,120,0,40)
mainBtn.Position = UDim2.new(0,20,0,100)
mainBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
mainBtn.TextColor3 = Color3.new(1,1,1)
mainBtn.Text = "⚡ Menu"
mainBtn.Parent = gui
mainBtn.Active = true
mainBtn.Draggable = true

local menu = Instance.new("Frame")
menu.Size = UDim2.new(0,180,0,160)
menu.Position = UDim2.new(0,0,1,0)
menu.BackgroundColor3 = Color3.fromRGB(30,30,30)
menu.Visible = false
menu.Parent = mainBtn

mainBtn.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
end)

--// SPEED x1.7
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0,150,0,40)
speedBtn.Position = UDim2.new(0,15,0,10)
speedBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
speedBtn.TextColor3 = Color3.new(1,1,1)
speedBtn.Text = "Speed x1.7 : OFF"
speedBtn.Parent = menu

local speedActive = false
local normalSpeed = 16
local boostSpeed = math.floor(normalSpeed * 1.7) -- 27

speedBtn.MouseButton1Click:Connect(function()
    speedActive = not speedActive
    speedBtn.Text = "Speed x1.7 : " .. (speedActive and "ON" or "OFF")

    local hum = getCharParts()
    if hum then
        hum.WalkSpeed = speedActive and boostSpeed or normalSpeed
    end
end)

plr.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").WalkSpeed = speedActive and boostSpeed or normalSpeed
end)

--// CLIMB
local climbBtn = Instance.new("TextButton")
climbBtn.Size = UDim2.new(0,150,0,40)
climbBtn.Position = UDim2.new(0,15,0,60)
climbBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
climbBtn.TextColor3 = Color3.new(1,1,1)
climbBtn.Text = "Climb : OFF"
climbBtn.Parent = menu

local climbActive = false
climbBtn.MouseButton1Click:Connect(function()
    climbActive = not climbActive
    climbBtn.Text = "Climb : " .. (climbActive and "ON" or "OFF")
end)

RunService.Heartbeat:Connect(function()
    if climbActive then
        local hum, hrp = getCharParts()
        if hum and hrp and hum.MoveDirection.Magnitude > 0 then
            local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 2)
            local hit = workspace:FindPartOnRay(ray, plr.Character)
            if hit then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 40, hrp.Velocity.Z)
            end
        end
    end
end)

--// ANTI FALL toggle
local antiFallBtn = Instance.new("TextButton")
antiFallBtn.Size = UDim2.new(0,150,0,40)
antiFallBtn.Position = UDim2.new(0,15,0,110)
antiFallBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
antiFallBtn.TextColor3 = Color3.new(1,1,1)
antiFallBtn.Text = "Anti Fall : OFF"
antiFallBtn.Parent = menu

local antiFallActive = false
antiFallBtn.MouseButton1Click:Connect(function()
    antiFallActive = not antiFallActive
    antiFallBtn.Text = "Anti Fall : " .. (antiFallActive and "ON" or "OFF")
end)

RunService.Heartbeat:Connect(function()
    if antiFallActive then
        local hum, hrp = getCharParts()
        if hum and hrp then
            if hrp.Position.Y < -5 or hum:GetState() == Enum.HumanoidStateType.Freefall then
                hrp.CFrame = CFrame.new(hrp.Position.X, math.max(hrp.Position.Y, 5), hrp.Position.Z)
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end
end)
