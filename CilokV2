-- Services
local P,U,R,W,L,TweenService = game:GetService("Players"),game:GetService("UserInputService"),game:GetService("RunService"),game:GetService("Workspace"),game:GetService("Lighting"),game:GetService("TweenService")
local pl = P.LocalPlayer
local climbMode,boostMode = false,false

-- Device
local function Device() if U.TouchEnabled and not U.KeyboardEnabled then return "Mobile" elseif U.TouchEnabled and U.KeyboardEnabled then return "Tablet" else return "PC" end end
local scaleDevice = {PC=1,Tablet=0.9,Mobile=0.7} local scale = scaleDevice[Device()]
local walkSpeed = {PC=16,Tablet=14,Mobile=13}
local boostSpeed = {PC=walkSpeed.PC*2,Tablet=walkSpeed.Tablet*2,Mobile=walkSpeed.Mobile*2}

-- GUI
local GUI = Instance.new("ScreenGui") GUI.IgnoreGuiInset=true GUI.ResetOnSpawn=false pcall(function() GUI.Parent=game.CoreGui end)
local mainToggle=Instance.new("Frame") mainToggle.Size=UDim2.new(0,180*scale,0,60*scale) mainToggle.Position=UDim2.new(0,20,0,80*scale) mainToggle.BackgroundColor3=Color3.fromRGB(40,40,40) mainToggle.BorderSizePixel=0 mainToggle.Parent=GUI
local toggleBtn=Instance.new("TextButton") toggleBtn.Size=UDim2.new(1,0,1,0) toggleBtn.BackgroundTransparency=1 toggleBtn.TextColor3=Color3.fromRGB(255,255,255) toggleBtn.Font=Enum.Font.GothamBold toggleBtn.TextScaled=true toggleBtn.Text="✨ Cilok Adventure" toggleBtn.Parent=mainToggle
local tagline=Instance.new("TextLabel") tagline.Size=UDim2.new(1,0,0,20*scale) tagline.Position=UDim2.new(0,0,1,0) tagline.Text="Universal Climbing Mate" tagline.TextColor3=Color3.fromRGB(200,200,200) tagline.BackgroundTransparency=1 tagline.Font=Enum.Font.Gotham tagline.TextScaled=true tagline.Parent=mainToggle

-- Draggable
local dragging,dragInput,dragStart,startPos
mainToggle.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true dragStart=input.Position startPos=mainToggle.Position input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end) end
end)
mainToggle.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end end)
R.RenderStepped:Connect(function() if dragging and dragInput then local delta=dragInput.Position-dragStart mainToggle.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y) end end)

-- Menu
local menu=Instance.new("Frame") menu.Size=UDim2.new(0,180*scale,0,60*scale) menu.Position=UDim2.new(0,0,1,5) menu.BackgroundColor3=Color3.fromRGB(30,30,30) menu.BackgroundTransparency=0.2 menu.Visible=false menu.BorderSizePixel=0 menu.Parent=mainToggle
local function AddHoverEffect(button) button.MouseEnter:Connect(function() TweenService:Create(button,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(80,80,80)}):Play() end) button.MouseLeave:Connect(function() TweenService:Create(button,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(60,60,60)}):Play() end) end
local function CreateBtn(text,posY) local btn=Instance.new("TextButton") btn.Size=UDim2.new(0,170*scale,0,25*scale) btn.Position=UDim2.new(0,5,0,posY) btn.Text=text btn.BackgroundColor3=Color3.fromRGB(60,60,60) btn.TextColor3=Color3.fromRGB(255,255,255) btn.Font=Enum.Font.GothamBold btn.TextScaled=true btn.Parent=menu AddHoverEffect(btn) return btn end
local climbBtn=CreateBtn("Climb",5)
local boostBtn=CreateBtn("Boost",35)
toggleBtn.MouseButton1Click:Connect(function() menu.Visible=not menu.Visible end)

-- Performance Mode Low-End
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

-- No fall damage + bouncing
task.spawn(function()
    repeat task.wait() until pl.Character and pl.Character:FindFirstChild("Humanoid")
    local hum = pl.Character:WaitForChild("Humanoid")
    local hrp = pl.Character:WaitForChild("HumanoidRootPart")

    R.Heartbeat:Connect(function()
        if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
    end)

    hum.StateChanged:Connect(function(_,state)
        if state==Enum.HumanoidStateType.Landed then
            local bouncePower = 2
            hrp.Velocity = Vector3.new(hrp.Velocity.X, bouncePower, hrp.Velocity.Z)
        end
    end)
end)

-- Climb Mode
local climbConn
local function ToggleClimb()
    if not pl.Character or not pl.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = pl.Character.HumanoidRootPart
    local hum = pl.Character:FindFirstChild("Humanoid")
    climbMode = not climbMode

    if climbMode then
        climbConn = R.Heartbeat:Connect(function()
            if not climbMode or not hrp or not hum then return end
            local moveDir = hum.MoveDirection
            local speed = boostMode and boostSpeed[Device()] or walkSpeed[Device()]
            hum:Move(moveDir*speed)

            -- Raycast forward untuk obstacle
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.FilterDescendantsInstances = {pl.Character}
            local fRay = workspace:Raycast(hrp.Position, moveDir*3, rayParams)
            if fRay then
                local obsHeight = fRay.Instance.Size.Y
                local targetY = hrp.Position.Y + math.min(obsHeight + 0.5, 1.2) -- lompatan wajar
                TweenService:Create(hrp, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {CFrame=CFrame.new(hrp.Position.X, targetY, hrp.Position.Z)}):Play()
                hrp.Velocity = Vector3.new(0,0,0)
            end
        end)
    else
        if climbConn then climbConn:Disconnect() end
    end
end

-- Boost
local function ToggleBoost()
    local hum=pl.Character and pl.Character:FindFirstChild("Humanoid")
    boostMode=not boostMode
    if hum then hum.WalkSpeed=boostMode and boostSpeed[Device()] or walkSpeed[Device()] end
end

climbBtn.MouseButton1Click:Connect(ToggleClimb)
boostBtn.MouseButton1Click:Connect(ToggleBoost)
