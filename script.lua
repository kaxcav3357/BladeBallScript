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
local parryCooldown = 0.3

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

    local function createToggle(name, stateVar, stateOnText, stateOffText)
        local button = Instance.new("TextButton")
        button.Name = name .. "Toggle"
        button.Size = UDim2.new(1, 0, 0, 25)
        button.Font = Enum.Font.SourceSansBold
        button.TextSize = 15
        button.TextColor3 = Color3.new(1, 1, 1)
        button.BorderSizePixel = 0
        button.Parent = paddingFrame

        local function updateButton()
            local enabled = _G[stateVar]
            button.Text = name .. " (" .. (enabled and stateOnText or stateOffText) .. ")"
            button.BackgroundColor3 = enabled and Color3.new(0, 0.6, 0) or Color3.new(0.4, 0.4, 0.4)
        end

        button.MouseButton1Click:Connect(function()
            _G[stateVar] = not _G[stateVar]
            updateButton()
        end)
        
        updateButton()
        return button
    end
    
    -- Agora todos os botões são criados de forma correta e consistente
    createToggle("Auto Parry", "isAutoParryEnabled", "ON", "OFF")
    createToggle("Aggressive Parry", "isAggressiveParryEnabled", "ON", "OFF")
    createToggle("Parry Spam", "isParrySpamEnabled", "ON", "OFF")
    createToggle("Auto Farm", "isAutoFarmEnabled", "ON", "OFF")
    createToggle("Fly", "isFlyEnabled", "ON", "OFF")
    createToggle("Speed", "isSpeedEnabled", "ON", "OFF")
end

-- ===[ CORE LOGIC ]===
local function getNearestBall()
    local nearestBall = nil
    local shortestDistance = math.huge
    local ballFolder = workspace:FindFirstChild("Balls") or workspace:FindFirstChild("TrainingBalls")
    
    if ballFolder then
        for _, ball in ipairs(ballFolder:GetChildren()) do
            if ball:IsA("Part") and ball:GetAttribute("realBall") then
                local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - ball.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestBall = ball
                end
            end
        end
    end
    return nearestBall, shortestDistance
end

local function StartSpammingClicks()
    if isSpamming then return end
    isSpamming = true
    task.spawn(function()
        while isSpamming do
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.03)
        end
    end)
end

local function StopSpammingClicks()
    isSpamming = false
end

RunService.PreSimulation:Connect(function()
    local player = Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
        StopSpammingClicks()
        return
    end

    local hrp = character.HumanoidRootPart
    local humanoid = character.Humanoid
    
    local ball, distance = getNearestBall()
    
    if not ball then
        StopSpammingClicks()
        if hrp:FindFirstChild("BodyPosition") then
            hrp:FindFirstChild("BodyPosition"):Destroy()
        end
        return
    end

    local ballTarget = ball:GetAttribute("target")
    local ballParried = ball:GetAttribute("parried")
    local speed = ball.zoomies.VectorVelocity.Magnitude
    
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
    
    if isSpeedEnabled then
        humanoid.WalkSpeed = 50
    else
        humanoid.WalkSpeed = 16
    end
    
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
            if ball.Velocity.Magnitude > 0 and ball:GetAttribute("target") == Players.LocalPlayer.Name then
                local predictedTime = distance / ball.Velocity.Magnitude
                if predictedTime <= 0.6 then
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                end
            end
        end
    else
        StopSpammingClicks()
    end
end)

createGui()
