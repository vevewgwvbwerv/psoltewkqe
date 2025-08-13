-- SIMPLE PET ANALYZER v1.0
-- Максимально простой анализатор питомцев без сложного GUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local backpack = player.Backpack

print("=== SIMPLE PET ANALYZER STARTED ===")
print("Monitoring backpack and hands for pets...")

-- Простые переменные для хранения данных
local petEvents = {}
local currentTool = nil

-- Простая функция логирования
local function logEvent(eventType, petName, details)
    local event = {
        time = tick(),
        type = eventType,
        pet = petName,
        details = details or {}
    }
    table.insert(petEvents, event)
    
    print(string.format("[%.2f] %s: %s", event.time, eventType, petName))
    if details then
        for key, value in pairs(details) do
            print(string.format("  %s: %s", key, tostring(value)))
        end
    end
end

-- Функция анализа Tool
local function analyzeTool(tool)
    if not tool then return {} end
    
    local data = {
        name = tool.Name,
        className = tool.ClassName
    }
    
    local handle = tool:FindFirstChild("Handle")
    if handle then
        data.handleSize = tostring(handle.Size)
        data.handlePosition = tostring(handle.Position)
        data.handleCFrame = tostring(handle.CFrame)
        
        -- Ищем Mesh
        for _, child in pairs(handle:GetChildren()) do
            if child:IsA("SpecialMesh") then
                data.meshId = child.MeshId
                data.textureId = child.TextureId
                data.meshScale = tostring(child.Scale)
                break
            end
        end
    end
    
    return data
end

-- Проверка является ли Tool питомцем
local function isPet(tool)
    if not tool then return false end
    local name = tool.Name
    return name:find("KG") or name:find("Dragonfly") or 
           name:find("{") or name:find("Pet") or name:find("pet")
end

-- Мониторинг Backpack
backpack.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        wait(0.1)
        if isPet(child) then
            local data = analyzeTool(child)
            logEvent("BACKPACK_ADDED", child.Name, data)
        end
    end
end)

-- Мониторинг Character
local function monitorCharacter(char)
    if not char then return end
    
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            wait(0.1)
            currentTool = child
            
            if isPet(child) then
                local data = analyzeTool(child)
                
                -- Дополнительный анализ позиции в руке
                local handle = child:FindFirstChild("Handle")
                if handle then
                    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                    if torso then
                        local relativePos = torso.CFrame:PointToObjectSpace(handle.Position)
                        data.relativeToTorso = tostring(relativePos)
                    end
                    
                    -- Анализ RightGrip
                    local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
                    if rightArm then
                        local rightGrip = rightArm:FindFirstChild("RightGrip")
                        if rightGrip then
                            data.rightGripC0 = tostring(rightGrip.C0)
                            data.rightGripC1 = tostring(rightGrip.C1)
                        end
                    end
                end
                
                logEvent("HAND_EQUIPPED", child.Name, data)
            end
        end
    end)
    
    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and child == currentTool then
            if isPet(child) then
                logEvent("HAND_REMOVED", child.Name)
            end
            currentTool = nil
        end
    end)
end

-- Запуск мониторинга
if character then
    monitorCharacter(character)
end

player.CharacterAdded:Connect(monitorCharacter)

-- Простые команды в чате
player.Chatted:Connect(function(message)
    local msg = message:lower()
    
    if msg == "/petreport" or msg == "/report" then
        print("\n=== PET ANALYSIS REPORT ===")
        print("Total events:", #petEvents)
        
        for i, event in ipairs(petEvents) do
            print(string.format("\n[%d] %s - %s (%.2f)", i, event.type, event.pet, event.time))
            
            if event.details.handleSize then
                print("  Handle Size:", event.details.handleSize)
            end
            if event.details.handlePosition then
                print("  Handle Position:", event.details.handlePosition)
            end
            if event.details.relativeToTorso then
                print("  Relative to Torso:", event.details.relativeToTorso)
            end
            if event.details.rightGripC0 then
                print("  RightGrip C0:", event.details.rightGripC0)
                print("  RightGrip C1:", event.details.rightGripC1)
            end
            if event.details.meshId then
                print("  Mesh ID:", event.details.meshId)
            end
        end
        print("=== END REPORT ===\n")
        
    elseif msg == "/petclear" or msg == "/clear" then
        petEvents = {}
        print("Pet analysis log cleared!")
        
    elseif msg == "/pethelp" or msg == "/help" then
        print("\n=== PET ANALYZER COMMANDS ===")
        print("/report or /petreport - Show analysis report")
        print("/clear or /petclear - Clear analysis log")
        print("/help or /pethelp - Show this help")
        print("=============================\n")
    end
end)

-- Статус каждые 10 секунд
spawn(function()
    while true do
        wait(10)
        print(string.format("Pet Analyzer Status: %d events recorded, Current tool: %s", 
              #petEvents, currentTool and currentTool.Name or "None"))
    end
end)

print("=== ANALYZER READY ===")
print("Commands: /report, /clear, /help")
print("Create a pet and take it in your hands to start analysis!")
