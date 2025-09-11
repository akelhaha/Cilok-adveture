-- iOS Friendly: Speed + Climb + Bouncing + Timer (minimalis, kanan bawah)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local plr = Players.LocalPlayer

-- Character refs
local char, hum, hrp
local function refreshCharRefs()
    char = plr.Character
    if not char then return end
    hum = char:FindFirstChildOfClass("Humanoid")
    hrp = char:FindFirstChild("HumanoidRootPart")
end
refreshCharRefs()
plr.CharacterAdded:Connect(function()
    wait(0.1)
    refreshCharRefs()
end)

-- Settings
local normalSpeed = 16
local boostMultiplier = 1.7
local boostSpeed = normalSpeed * boostMultiplier
local climbVelocityY = 40
local bounceVelocity = 30
local fallThreshold = -50
local summitY = 8848 -- puncak Gunung Everest

-- State
local speedActive = false
local climbActive = false
local climbTimerActive = false
local climbStartTime = 0

-- GUI
local playerGui = plr:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "iPhoneClimbGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Timer Label (minimalis, semi transparan, tanpa background)
local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0,80,0,30)
timerLabel.Position = UDim2.new(1,-100,1,-50) -- kanan bawah
timerLabel.BackgroundTransparency = 1 -- tanpa background
timerLabel.TextColor3 = Color3.fromRGB(255,255,255)
timerLabel.TextScaled = true
timerLabel.Text = "00:00"
timerLabel.Parent = screenGui

-- Main Menu Button
local mainBtn = Instance.new("TextButton")
mainBtn.Size = UDim2.new(0,140,0,42)
mainBtn.Position = UDim2.new(0,18,0,100)
mainBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
mainBtn.TextColor3 = Color3.fromRGB(255,255,255)
mainBtn.Text = "⚡ Menu"
mainBtn.Parent = screenGui
mainBtn.Active = true
mainBtn.Draggable = true

local menu = Instance.new("Frame")
menu.Size = UDim2.new(0,200,0,100)
menu.Position = UDim2.new(0,0,1,0)
menu.BackgroundColor3 = Color3.fromRGB(30,30,30)
menu.Visible = false
menu.Parent = mainBtn

mainBtn.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
end)

-- Speed toggle
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0,170,0,36)
speedBtn.Position = UDim2.new(0,15,0,10)
speedBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
speedBtn.TextColor3 = Color3.fromRGB(255,255,255)
speedBtn.Text = "Speed x1.7 : OFF"
speedBtn.Parent = menu

speedBtn.MouseButton1Click:Connect(function()
    speedActive = not speedActive
    speedBtn.Text = "Speed x1.7 : " .. (speedActive and "ON" or "OFF")
    if hum then hum.WalkSpeed = speedActive and boostSpeed or normalSpeed end
end)

-- Climb toggle
local climbBtn = Instance.new("TextButton")
climbBtn.Size = UDim2.new(0,170,0,36)
climbBtn.Position = UDim2.new(0,15,0,54)
climbBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
climbBtn.TextColor3 = Color3.fromRGB(255,255,255)
climbBtn.Text = "Climb : OFF"
climbBtn.Parent = menu

climbBtn.MouseButton1Click:Connect(function()
    climbActive = not climbActive
    climbBtn.Text = "Climb : " .. (climbActive and "ON" or "OFF")

    if climbActive and not climbTimerActive then
        climbTimerActive = true
        climbStartTime = tick()
    end
end)

-- Heartbeat: handle climb, bouncing, timer
RunService.Heartbeat:Connect(function(dt)
    if not char or not hum or not hrp then refreshCharRefs() end
    if not hum or not hrp then return end

    -- enforce WalkSpeed
    hum.WalkSpeed = speedActive and boostSpeed or normalSpeed

    -- Climb
    if climbActive then
        if hum.MoveDirection.Magnitude > 0 then
            local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector*2)
            if Workspace:FindPartOnRay(ray,char) then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, climbVelocityY, hrp.Velocity.Z)
            end
        end
    end

    -- Bouncing
    if hum:GetState() == Enum.HumanoidStateType.Freefall and hrp.Velocity.Y < fallThreshold then
        hrp.Velocity = Vector3.new(hrp.Velocity.X, bounceVelocity, hrp.Velocity.Z)
    end

    -- Update Timer
    if climbTimerActive then
        local elapsed = tick() - climbStartTime
        local minutes = math.floor(elapsed / 60)
        local seconds = math.floor(elapsed % 60)
        timerLabel.Text = string.format("%02d:%02d", minutes, seconds)

        -- Hentikan timer jika sampai puncak
        if hrp.Position.Y >= summitY then
            climbTimerActive = false
        end
    end
end)

-- Reapply on respawn & reset timer
plr.CharacterAdded:Connect(function()
    wait(0.2)
    refreshCharRefs()
    if hum then hum.WalkSpeed = speedActive and boostSpeed or normalSpeed end

    -- Reset timer saat respawn
    climbTimerActive = false
    timerLabel.Text = "00:00"
end)
