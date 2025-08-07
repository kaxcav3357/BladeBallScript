local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local isAutoParryEnabled = false
local isAutoFarmEnabled = false
local isFlyEnabled = false
local isSpeedEnabled = false
local ballToParry = nil
local flyVelocity = nil
local lastParryTime = 0
local parryCooldown = 0.5 -- 0.5 segundos de cooldown entre os parries para evitar travamento

local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -100, 0.5, -125)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.Parent = screenGui

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    titleLabel.Text = "DAN's Blade Ball Hub"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.SourceSans
    titleLabel.TextSize = 16
    titleLabel.Parent = mainFrame
    
    local dragging
    local dragStart
    local dragInput
    
    titleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            dragInput = input
        end
    end)
    
    titleLabel.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset + delta.X,
                                      mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset + delta.Y)
            mainFrame.Position = newPos
            dragStart = input.Position
        end
    end)

    -- Botão para o Auto Parry
    local autoParryButton = Instance.new("TextButton")
    autoParryButton.Size = UDim2.new(1, -20, 0, 30)
    autoParryButton.Position = UDim2.new(0, 10, 0, 30)
    autoParryButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    autoParryButton.Text = "Auto Parry: OFF"
    autoParryButton.TextColor3 = Color3.new(1, 1, 1)
    autoParryButton.Font = Enum.Font.SourceSans
    autoParryButton.TextSize = 14
    autoParryButton.Parent = mainFrame
    
    autoParryButton.MouseButton1Click:Connect(function()
        isAutoParryEnabled = not isAutoParryEnabled
        if isAutoParryEnabled then
            autoParryButton.Text = "Auto Parry: ON"
            autoParryButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        else
            autoParryButton.Text = "Auto Parry: OFF"
            autoParryButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end)

    -- Botão para o Auto Farm
    local autoFarmButton = Instance.new("TextButton")
    autoFarmButton.Size = UDim2.new(1, -20, 0, 30)
    autoFarmButton.Position = UDim2.new(0, 10, 0, 70)
    autoFarmButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    autoFarmButton.Text = "Auto Farm: OFF"
    autoFarmButton.TextColor3 = Color3.new(1, 1, 1)
    autoFarmButton.Font = Enum.Font.SourceSans
    autoFarmButton.TextSize = 14
    autoFarmButton.Parent = mainFrame
    
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

    -- Botão para o Fly
    local flyButton = Instance.new("TextButton")
    flyButton.Size = UDim2.new(1, -20, 0, 30)
    flyButton.Position = UDim2.new(0, 10, 0, 110)
    flyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    flyButton.Text = "Fly: OFF"
    flyButton.TextColor3 = Color3.new(1, 1, 1)
    flyButton.Font = Enum.Font.SourceSans
    flyButton.TextSize = 14
    flyButton.Parent = mainFrame
    
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
    speedButton.Size = UDim2.new(1, -20, 0, 30)
    speedButton.Position = UDim2.new(0, 10, 0, 150)
    speedButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    speedButton.Text = "Speed: OFF"
    speedButton.TextColor3 = Color3.new(1, 1, 1)
    speedButton.Font = Enum.Font.SourceSans
    speedButton.TextSize = 14
    speedButton.Parent = mainFrame
    
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
    
    return mainFrame
end

local function mainLoop()
    while true do
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
            task.wait()
            continue
        end

        local rootPart = character.HumanoidRootPart
        local humanoid = character.Humanoid

        if isAutoParryEnabled and (os.clock() - lastParryTime) > parryCooldown then
            for _, v in pairs(Workspace:GetChildren()) do
                if v.Name == "Ball" and v:FindFirstChild("BodyVelocity") then
                    local playerPosition = rootPart.Position
                    local ballPosition = v.Position
                    
                    if (playerPosition - ballPosition).magnitude < 15 and v.BodyVelocity.Velocity.magnitude > 50 then
                        if ballToParry ~= v then
                            local remoteEvent = ReplicatedStorage:WaitForChild("ParryEvent")
                            remoteEvent:FireServer()
                            lastParryTime = os.clock()
                            ballToParry = v
                            break
                        end
                    end
                else
                    ballToParry = nil
                end
            end
        end

        if isAutoFarmEnabled then
            if Workspace:FindFirstChild("Ball") then
                local ball = Workspace:FindFirstChild("Ball")
                if ball and ball:FindFirstChild("BodyVelocity") then
                    local ballPosition = ball.Position
                    local directionToBall = (rootPart.Position - ballPosition).unit
                    local farmPosition = ballPosition + (directionToBall * 15)
                    
                    if not rootPart:FindFirstChild("BodyPosition") then
                        local bodyPosition = Instance.new("BodyPosition")
                        bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bodyPosition.D = 100
                        bodyPosition.P = 10000
                        bodyPosition.Parent = rootPart
                    end
                    rootPart.BodyPosition.Position = farmPosition
                end
            end
        else
            if rootPart:FindFirstChild("BodyPosition") then
                rootPart:FindFirstChild("BodyPosition"):Destroy()
            end
        end

        if isFlyEnabled then
            humanoid.PlatformStand = true
            
            if not flyVelocity then
                flyVelocity = Instance.new("BodyVelocity")
                flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                flyVelocity.Velocity = Vector3.new(0, 0, 0)
                flyVelocity.Parent = rootPart
            end
            
            local move = game:GetService("UserInputService"):GetMouseDelta()
            local moveVector = Vector3.new(move.X, 0, move.Y)
            flyVelocity.Velocity = (rootPart.CFrame.rightVector * moveVector.X * 50) + (rootPart.CFrame.lookVector * moveVector.Z * 50)
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

        task.wait()
    end
end

createGUI()
task.spawn(mainLoop)
