-- Simulação de variáveis e funções do Roblox (para desenvolvimento no Codea)
local LocalPlayer = {
    Character = {
        HumanoidRootPart = {
            Position = {x = 0, y = 0, z = 0}
        }
    }
}

local workspace = {
    Ball = {
        Position = {x = 10, y = 0, z = 0}
    }
}

local AutoParryEnabled = false

function toggleAutoParry()
    AutoParryEnabled = not AutoParryEnabled
    print("Auto Parry:", AutoParryEnabled)
end

-- Simulação do UserInputService
local keysPressed = {}

function keyPressed(key)
    keysPressed[key] = true
    if key == "p" then
        toggleAutoParry()
    end
end

function keyReleased(key)
    keysPressed[key] = nil
end

-- Simulação do RunService.Stepped
function gameLoop()
    if AutoParryEnabled then
        if workspace.Ball and LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
            local ballPosition = workspace.Ball.Position
            local myPosition = LocalPlayer.Character.HumanoidRootPart.Position
            local dx = myPosition.x - ballPosition.x
            local dy = myPosition.y - ballPosition.y
            local dz = myPosition.z - ballPosition.z
            local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
            print("Distância da bola:", distance)
            if distance < 5 then
                print("Bola muito perto! (Simulação de possível parry)")
                -- No Roblox, aqui você tentaria acionar a ação de parry
            end
        end
    end
    
    -- Simulação do movimento Fly (bem rudimentar)
    if keysPressed["w"] then
        LocalPlayer.Character.HumanoidRootPart.Position.z = LocalPlayer.Character.HumanoidRootPart.Position.z + 0.5
    end -- Fim do if keysPressed["w"]
    if keysPressed["s"] then
        LocalPlayer.Character.HumanoidRootPart.Position.z = LocalPlayer.Character.HumanoidRootPart.Position.z - 0.5
    end -- Fim do if keysPressed["s"]
    if keysPressed["a"] then
        LocalPlayer.Character.HumanoidRootPart.Position.x = LocalPlayer.Character.HumanoidRootPart.Position.x - 0.5
    end -- Fim do if keysPressed["a"]
    if keysPressed["d"] then
        LocalPlayer.Character.HumanoidRootPart.Position.x = LocalPlayer.Character.HumanoidRootPart.Position.x + 0.5
    end -- Fim do if keysPressed["d"]
    if keysPressed["space"] then
        LocalPlayer.Character.HumanoidRootPart.Position.y = LocalPlayer.Character.HumanoidRootPart.Position.y + 0.5
    end -- Fim do if keysPressed["space"]
    if keysPressed["leftshift"] then
        LocalPlayer.Character.HumanoidRootPart.Position.y = LocalPlayer.Character.HumanoidRootPart.Position.y - 0.5
    end -- Fim do if keysPressed["leftshift"]
    
    -- Atualiza a posição da bola para simular movimento
    workspace.Ball.Position.x = workspace.Ball.Position.x - 0.1
end -- Fim da função gameLoop

-- Simulação de pressionar a tecla 'p' para ativar o Auto Parry
keyPressed("p")

-- Inicia o loop de jogo simulado
function loop()
    gameLoop()
end

-- Simulação de pressionar teclas para o "Fly" (executadas apenas uma vez agora)
keyPressed("w")
keyPressed("space")
