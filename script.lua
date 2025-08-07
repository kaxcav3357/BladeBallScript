-- Script do Painel com todas as funcionalidades (versão 2.0)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local isAutoParryEnabled = false
local isAggressiveParryEnabled = false
local isParrySpamEnabled = false
local isAutoFarmEnabled = false
local isFlyEnabled = false
local isSpeedEnabled = false
local flyVelocity = nil

local lastParryTime = 0
local parryCooldown = 0.3 -- Cooldown para evitar travamento

local isSpamming = false
local spamTask = nil

-- ===[ GUI SETUP ]===
local screenGui
local function createGui()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BladeBallProGUI_DAN"
    screenGui.Parent = CoreGui
    screenGui.ResetOnSpawn = false
    screenGui.Enabled = true

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 200, 0, 250)
    mainFrame.Position = UDim2.new(1, -210, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.new(0.05, 0.05, 0.05)
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    local titleBar = Instance.new("TextLabel")
    titleBar.Size = UDim2.new(1, 0, 0, 20)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.Font = Enum.Font.SourceSansBold
    titleBar.TextSize = 16
    titleBar.Text = "Blade Ball DAN Edition"
    titleBar.TextColor3 = Color3.new(1, 1, 1)
    titleBar.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
    titleBar.Parent = mainFrame
    
    local paddingFrame = Instance.new("Frame")
    paddingFrame.Size = UDim2.new(1, -10, 1, -20)
    paddingFrame.Position = UDim2.new(0, 5, 0, 25)
    paddingFrame.BackgroundTransparency = 1
    paddingFrame.Parent = mainFrame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = paddingFrame

    local function createToggle(name, stateKey, textOn, textOff)
        local button = Instance.new("TextButton")
        button.Name = name .. "Toggle"
        button.Size = UDim2.new(1, 0, 0, 25)
        button.Font = Enum.Font.SourceSansBold
        button.TextSize = 15
        button.TextColor3 = Color3.new(1, 1, 1)
        button.BorderSizePixel = 0
        button.Parent = paddingFrame

        local function updateButton()
            button.Text = name .. " (" .. (enabled[stateKey] and textOn or textOff) .. ")"
            button.BackgroundColor3 = enabled[stateKey] and Color3.new(0, 0.6, 0) or Color3.new(0.4, 0.4, 0.4)
        end

        button.MouseButton1Click:Connect(function()
            enabled[stateKey] = not enabled[stateKey]
            updateButton()
        end)
        
        updateButton()
        return button
    end
    
    local enabled = {
        Parry = false,
        AggressiveParry = false,
        SpamParry = false,
        Aim = false,
        Walk = false
    }

    createToggle("Auto Parry", "Parry", "ON", "OFF")
    createToggle("Aggressive Parry", "AggressiveParry", "ON", "OFF")
    createToggle("Parry Spam", "SpamParry", "ON", "OFF")
    createToggle("Auto Walk", "Walk", "ON", "OFF")
    
    -- Botão para o Fly
    local flyButton = Instance.new("TextButton")
    flyButton.Size = UDim2.new(1, 0, 0, 25)
    flyButton.Position = UDim2.new(0, 0, 0, 150)
    flyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    flyButton.Text = "Fly: OFF"
    flyButton.TextColor3 = Color3.new(1, 1, 1)
    flyButton.Font = Enum.Font.SourceSans
    flyButton.TextSize = 14
    flyButton.Parent = paddingFrame
    
    flyButton.MouseButton1Click:Connect(function()
        isFlyEnabled = not isFlyEnabled
        if isFlyEnabled then
            flyButton.Text = "Fly: ON"
            flyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        else
            flyButton.Text = "Fly: OFF"
            flyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end)

    -- Botão para o Speed
    local speedButton = Instance.new("TextButton")
    speedButton.Size = UDim2.new(1, 0, 0, 25)
    speedButton.Position = UDim2.new(0, 0, 0, 180)
    speedButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    speedButton.Text = "Speed: OFF"
    speedButton.TextColor3 = Color3.new(1, 1, 1)
    speedButton.Font = Enum.Font.SourceSans
    speedButton.TextSize = 14
    speedButton.Parent = paddingFrame
    
    speedButton.MouseButton1Click:Connect(function()
        isSpeedEnabled = not isSpeedEnabled
        if isSpeedEnabled then
            speedButton.Text = "Speed: ON"
            speedButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        else
            speedButton.Text = "Speed: OFF"
            speedButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end)
    
    -- Botão para o Auto Farm
    local autoFarmButton = Instance.new("TextButton")
    autoFarmButton.Size = UDim2.new(1, 0, 0, 25)
    autoFarmButton.Position = UDim2.new(0, 0, 0, 210)
    autoFarmButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    autoFarmButton.Text = "Auto Farm: OFF"
    autoFarmButton.TextColor3 = Color3.new(1, 1, 1)
    autoFarmButton.Font = Enum.Font.SourceSans
    autoFarmButton.TextSize = 14
    autoFarmButton.Parent = paddingFrame
    
    autoFarmButton.MouseButton1Click:Connect(function()
        isAutoFarmEnabled = not isAutoFarmEnabled
        if isAutoFarmEnabled then
            autoFarmButton.Text = "Auto Farm: ON"
            autoFarmButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        else
            autoFarmButton.Text = "Auto Farm: OFF"
            autoFarmButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end)
end

-- ===[ CORE LOGIC ]===
local function GetBallFromFolder(folder)
    for _, ball in ipairs(folder:GetChildren()) do
        if ball:GetAttribute("realBall") then
            return ball
        end
    end
    return nil
end

local function StartSpammingClicks()
    if isSpamming then return end
    isSpamming = true
    task.spawn(function()
        while isSpamming do
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.03) -- Intervalo de spam
        end
    end)
end

local function StopSpammingClicks()
    isSpamming = false
end

-- Main Loop
RunService.PreSimulation:Connect(function()
    local player = Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
        StopSpammingClicks()
        return
    end

    local hrp = character.HumanoidRootPart
    local humanoid = character.Humanoid
    
    local ballFolder = workspace:FindFirstChild("Balls")
    if not ballFolder then
        ballFolder = workspace:FindFirstChild("TrainingBalls")
    end
    
    if not ballFolder then
        StopSpammingClicks()
        return
    end

    local ball = GetBallFromFolder(ballFolder)
    
    if not ball then
        StopSpammingClicks()
        -- Auto Farm
        if hrp:FindFirstChild("BodyPosition") then
            hrp:FindFirstChild("BodyPosition"):Destroy()
        end
        return
    end

    local distance = (hrp.Position - ball.Position).Magnitude
    local ballTarget = ball:GetAttribute("target")
    local ballParried = ball:GetAttribute("parried")
    local speed = ball.zoomies.VectorVelocity.Magnitude

    -- Lógica do Auto Farm
    if isAutoFarmEnabled then
        local directionToBall = (hrp.Position - ball.Position).unit
        local farmPosition = ball.Position + (directionToBall * 15)
        
        if not hrp:FindFirstChild("BodyPosition") then
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyPosition.D = 100
            bodyPosition.P = 10000
            bodyPosition.Parent = hrp
        end
        hrp.BodyPosition.Position = farmPosition
    else
        if hrp:FindFirstChild("BodyPosition") then
            hrp:FindFirstChild("BodyPosition"):Destroy()
        end
    end

    -- Lógica do Fly
    if isFlyEnabled then
        humanoid.PlatformStand = true
        if not flyVelocity then
            flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            flyVelocity.Velocity = Vector3.new(0, 0, 0)
            flyVelocity.Parent = hrp
        end
        local move = UserInputService:GetMouseDelta()
        local moveVector = Vector3.new(move.X, 0, move.Y)
        flyVelocity.Velocity = (hrp.CFrame.rightVector * moveVector.X * 50) + (hrp.CFrame.lookVector * moveVector.Z * 50)
    else
        if humanoid.PlatformStand then
            humanoid.PlatformStand = false
        end
        if flyVelocity then
            flyVelocity:Destroy()
            flyVelocity = nil
        end
    end
    
    -- Lógica do Speed
    if isSpeedEnabled then
        humanoid.WalkSpeed = 50
    else
        humanoid.WalkSpeed = 16
    end
    
    -- Nova lógica do Auto Parry
    if isAutoParryEnabled and ballTarget == player.Name and not ballParried and speed > 0 and (os.clock() - lastParryTime) > parryCooldown then
        if isParrySpamEnabled then
            if distance <= 40 then
                StartSpammingClicks()
            else
                StopSpammingClicks()
            end
        elseif isAggressiveParryEnabled then
            StopSpammingClicks()
            local adjustedDistanceLimit = 35
            if speed > 70 then
                adjustedDistanceLimit = 35 * (speed / 70)
            end
            
            if distance <= adjustedDistanceLimit then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                lastParryTime = os.clock()
                ball:SetAttribute("parried", true)
            end
        else
            StopSpammingClicks()
            -- Lógica preditiva (simplificada)
            local predictedTime = distance / speed
            if predictedTime <= 0.55 then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                lastParryTime = os.clock()
                ball:SetAttribute("parried", true)
            end
        end
    else
        StopSpammingClicks()
    end
end)

createGui()
