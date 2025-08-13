-- Services
local P = game:GetService("Players")
local U = game:GetService("UserInputService")
local R = game:GetService("RunService")
local W = game:GetService("Workspace")
local L = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- Player
local pl = P.LocalPlayer
local fMode, nMode = false, false

-- Device detection
local function Device()
    if U.TouchEnabled and not U.KeyboardEnabled then return "Mobile"
    elseif U.TouchEnabled and U.KeyboardEnabled then return "Tablet"
    else return "PC" end
end

local deviceScale = {PC=1, Tablet=0.9, Mobile=0.7}
local scale = deviceScale[Device()]

local walkSpeed = {PC=16, Tablet=14, Mobile=13}
local boostSpeed = {PC=50, Tablet=40, Mobile=35}

-- GUI
local GUI = Instance.new("ScreenGui")
GUI.IgnoreGuiInset = true
GUI.ResetOnSpawn = false
pcall(function() GUI.Parent = game:GetService("CoreGui") end)

-- Draggable Main Toggle
local mainToggle = Instance.new("Frame")
mainToggle.Size = UDim2.new(0, 180*scale, 0, 50*scale)
mainToggle.Position = UDim2.new(0, 20, 0, 80*scale)
mainToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainToggle.BorderSizePixel = 0
mainToggle.Parent = GUI

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextScaled = true
toggleBtn.Text = "✨ Cilok Adventure"
toggleBtn.Parent = mainToggle

-- Make draggable
local dragging, dragInput, dragStart, startPos
mainToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainToggle.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainToggle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

R.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        mainToggle.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Menu container
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 180*scale, 0, 70*scale)
menu.Position = UDim2.new(0, 0, 1, 5)
menu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menu.BackgroundTransparency = 0.2
menu.Visible = false
menu.BorderSizePixel = 0
menu.Parent = mainToggle

-- Smooth hover effect
local function AddHoverEffect(button)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
    end)
end

-- Buttons inside menu
local function CreateBtn(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 170*scale, 0, 25*scale)
    btn.Position = UDim2.new(0, 5, 0, posY)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.Parent = menu
    AddHoverEffect(btn)
    return btn
end

local flyBtn = CreateBtn("Fly", 5)
local boostBtn = CreateBtn("Boost", 40)

toggleBtn.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
end)

-- Compass
local compass = Instance.new("ImageLabel")
compass.Size = UDim2.new(0, 80*scale, 0, 80*scale)
compass.Position = UDim2.new(1, -90*scale, 0, 10*scale)
compass.BackgroundTransparency = 1
compass.Image = "rbxassetid://10369542556"
compass.Parent = GUI

-- Performance Mode
task.spawn(function()
    while true do
        for _,plr in pairs(P:GetPlayers()) do
            if plr~=pl and plr.Character then
                for _,d in pairs(plr.Character:GetDescendants()) do
                    if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") then d.Enabled=false
                    elseif d:IsA("BasePart") or d:IsA("Decal") then d.Transparency=0.5 end
                end
            end
        end
        L.GlobalShadows=false
        L.OutdoorAmbient=Color3.fromRGB(200,200,200)
        task.wait(1)
    end
end)

-- No fall damage
task.spawn(function()
    repeat task.wait() until pl.Character and pl.Character:FindFirstChild("Humanoid")
    local hum = pl.Character:WaitForChild("Humanoid")
    hum.StateChanged:Connect(function(_,st)
        if st==Enum.HumanoidStateType.Landed then hum.Health=hum.MaxHealth end
    end)
end)

-- Fly
local bg
local fConnection
local function DisableHumanoidAnim(hum)
    for _,track in pairs(hum:GetPlayingAnimationTracks()) do track:Stop() end
end

local function FlyStepBouncing(hrp, hum)
    local move = hum.MoveDirection
    local velY = 0
    if U:IsKeyDown(Enum.KeyCode.Space) then velY = 50 end
    if U:IsKeyDown(Enum.KeyCode.LeftShift) then velY = -50 end

    local rayForward = Ray.new(hrp.Position, move*3)
    local hitF = workspace:FindPartOnRay(rayForward, pl.Character)

    local rayUp = Ray.new(hrp.Position + Vector3.new(0,2,0), Vector3.new(0,3,0))
    local hitU = workspace:FindPartOnRay(rayUp, pl.Character)

    if hitF or hitU then
        TweenService:Create(hrp, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + 5, hrp.Position.Z)
        }):Play()
    end

    hrp.Velocity = move*60 + Vector3.new(0, velY, 0)
    DisableHumanoidAnim(hum)
end

local function ToggleFly()
    if not pl.Character or not pl.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = pl.Character.HumanoidRootPart
    local hum = pl.Character:FindFirstChild("Humanoid")
    fMode = not fMode
    if fMode then
        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp

        fConnection = R.RenderStepped:Connect(function()
            if not fMode or not hrp or not hum then return end
            FlyStepBouncing(hrp, hum)
            bg.CFrame = CFrame.new(hrp.Position, hrp.Position + workspace.CurrentCamera.CFrame.LookVector)
        end)
    else
        if bg then bg:Destroy() end
        if fConnection then fConnection:Disconnect() end
    end
end

-- Boost
local function ToggleBoost()
    local hum = pl.Character and pl.Character:FindFirstChild("Humanoid")
    nMode = not nMode
    if hum then
        hum.WalkSpeed = nMode and boostSpeed[Device()] or walkSpeed[Device()]
    end
end

-- Connect buttons
flyBtn.MouseButton1Click:Connect(ToggleFly)
boostBtn.MouseButton1Click:Connect(ToggleBoost)
