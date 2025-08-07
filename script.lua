local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local isAutoParryEnabled = true -- Já deixei ativado para você testar
local lastParryTime = 0
local parryCooldown = 0.3

-- Função para simular o clique do mouse
local function doParry()
    local mouse = Players.LocalPlayer:GetMouse()
    mouse.Button1Down:Fire()
    task.wait(0.1)
    mouse.Button1Up:Fire()
end

-- Função para encontrar a bola mais próxima
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

RunService.PreSimulation:Connect(function()
    local player = Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local hrp = character.HumanoidRootPart
    local ball, distance = getNearestBall()

    if not ball then
        return
    end

    local ballTarget = ball:GetAttribute("target")
    local ballParried = ball:GetAttribute("parried")
    local speed = ball.zoomies.VectorVelocity.Magnitude
    
    if isAutoParryEnabled and ballTarget == player.Name and not ballParried and speed > 0 and (os.clock() - lastParryTime) > parryCooldown then
        -- Lógica de parry aprimorada
        if ball.Velocity.Magnitude > 0 and ball:GetAttribute("target") == Players.LocalPlayer.Name then
            local predictedTime = distance / ball.Velocity.Magnitude
            if predictedTime <= 0.6 then
                doParry()
                lastParryTime = os.clock()
                ball:SetAttribute("parried", true)
            end
        end
    end
end)
