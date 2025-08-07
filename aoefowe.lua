-- 🔍 ДИАГНОСТИКА CFrame АНИМАЦИИ DRAGONFLY
-- Анализирует почему крылья и хвост не анимируются в копии

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

print("🔍 === ДИАГНОСТИКА CFrame АНИМАЦИИ DRAGONFLY ===")

-- 🎯 Функция поиска питомца в руке
local function findHandHeldPet()
    local player = Players.LocalPlayer
    if not player then return nil end
    
    local character = player.Character
    if not character then return nil end
    
    local handTool = character:FindFirstChildOfClass("Tool")
    if not handTool then return nil end
    
    print("🎯 Найден Tool в руке:", handTool.Name)
    return handTool
end

-- 📦 Функция получения всех анимируемых частей из Tool
local function getAnimatedPartsFromTool(tool)
    local parts = {}
    
    if not tool then return parts end
    
    for _, obj in pairs(tool:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "Handle" then
            table.insert(parts, obj)
        end
    end
    
    return parts
end

-- 🔍 Функция поиска копии питомца В РУКЕ (второй Tool)
local function findPetCopyInHand()
    local player = Players.LocalPlayer
    if not player then return nil end
    
    local character = player.Character
    if not character then return nil end
    
    -- Ищем ВСЕ Tool в руках
    local tools = {}
    for _, obj in pairs(character:GetChildren()) do
        if obj:IsA("Tool") then
            table.insert(tools, obj)
        end
    end
    
    print(string.format("🔍 Найдено Tool в руках: %d", #tools))
    
    -- Если есть 2 Tool - один оригинал, один копия
    if #tools >= 2 then
        -- Копия обычно больше по размеру или имеет больше частей
        local bestCopy = nil
        local maxParts = 0
        
        for _, tool in ipairs(tools) do
            local parts = 0
            for _, obj in pairs(tool:GetDescendants()) do
                if obj:IsA("BasePart") then
                    parts = parts + 1
                end
            end
            
            print(string.format("  - %s: %d частей", tool.Name, parts))
            
            if parts > maxParts then
                maxParts = parts
                bestCopy = tool
            end
        end
        
        if bestCopy then
            print("🎯 Найдена копия в руке:", bestCopy.Name)
            return bestCopy
        end
    elseif #tools == 1 then
        print("⚠️ Найден только 1 Tool - возможно копия не создана")
        return tools[1]  -- Возвращаем единственный Tool для анализа
    end
    
    return nil
end

-- 📊 Функция анализа частей модели
local function analyzeParts(model, modelName)
    print(string.format("\n📊 === АНАЛИЗ ЧАСТЕЙ: %s ===", modelName))
    
    local parts = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        end
    end
    
    print(string.format("📦 Всего BasePart: %d", #parts))
    
    -- Группируем части по типам
    local partsByName = {}
    for _, part in ipairs(parts) do
        local name = part.Name
        if not partsByName[name] then
            partsByName[name] = 0
        end
        partsByName[name] = partsByName[name] + 1
    end
    
    print("📋 Части по именам:")
    for name, count in pairs(partsByName) do
        print(string.format("  - %s: %d шт", name, count))
    end
    
    return parts, partsByName
end

-- 🎯 Функция поиска соответствующей части в копии
local function findCorrespondingPart(copyModel, partName)
    for _, obj in pairs(copyModel:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == partName then
            return obj
        end
    end
    return nil
end

-- 🔍 ОСНОВНАЯ ДИАГНОСТИКА
local function runDiagnostic()
    print("\n🔍 === ЗАПУСК ДИАГНОСТИКИ CFrame АНИМАЦИИ ===")
    
    -- 1. Ищем питомца в руке
    local handTool = findHandHeldPet()
    if not handTool then
        print("❌ Питомец в руке не найден!")
        return
    end
    
    -- 2. Анализируем части в Tool
    local handParts = getAnimatedPartsFromTool(handTool)
    print(string.format("📦 Анимируемых частей в Tool: %d", #handParts))
    
    local _, handPartsByName = analyzeParts(handTool, "TOOL В РУКЕ")
    
    -- 3. Ищем копию в руке (второй Tool)
    local copyModel = findPetCopyInHand()
    if not copyModel then
        print("❌ Копия питомца в руке не найдена!")
        print("📝 Создай копию через PetScaler сначала!")
        return
    end
    
    -- 4. Анализируем части в копии
    local _, copyPartsByName = analyzeParts(copyModel, "КОПИЯ В РУКЕ")
    
    -- 5. Сравниваем части
    print("\n🔄 === СРАВНЕНИЕ ЧАСТЕЙ ===")
    local foundParts = 0
    local missingParts = 0
    
    for _, handPart in ipairs(handParts) do
        local partName = handPart.Name
        local copyPart = findCorrespondingPart(copyModel, partName)
        
        if copyPart then
            foundParts = foundParts + 1
            print(string.format("✅ НАЙДЕНА: %s", partName))
        else
            missingParts = missingParts + 1
            print(string.format("❌ НЕ НАЙДЕНА: %s", partName))
        end
    end
    
    print(string.format("\n📊 РЕЗУЛЬТАТ СРАВНЕНИЯ:"))
    print(string.format("✅ Найдено частей: %d", foundParts))
    print(string.format("❌ Не найдено частей: %d", missingParts))
    print(string.format("📈 Процент совпадения: %.1f%%", (foundParts / #handParts) * 100))
    
    -- 6. Анализ CFrame изменений
    if foundParts > 0 then
        print("\n🎬 === АНАЛИЗ CFrame ИЗМЕНЕНИЙ ===")
        print("Отслеживаю изменения CFrame в течение 10 секунд...")
        
        local previousStates = {}
        local changeCount = 0
        
        -- Инициализируем начальные состояния
        for _, handPart in ipairs(handParts) do
            if handPart and handPart.Parent then
                previousStates[handPart.Name] = handPart.CFrame
            end
        end
        
        local startTime = tick()
        local connection
        
        connection = RunService.Heartbeat:Connect(function()
            local currentTime = tick()
            
            -- Проверяем изменения каждые 0.1 секунды
            if (currentTime - startTime) % 0.1 < 0.016 then
                for _, handPart in ipairs(handParts) do
                    if handPart and handPart.Parent then
                        local partName = handPart.Name
                        local currentCFrame = handPart.CFrame
                        
                        if previousStates[partName] then
                            local prevCFrame = previousStates[partName]
                            local positionDiff = (currentCFrame.Position - prevCFrame.Position).Magnitude
                            local rotationDiff = math.abs(currentCFrame.LookVector:Dot(prevCFrame.LookVector) - 1)
                            
                            if positionDiff > 0.001 or rotationDiff > 0.001 then
                                changeCount = changeCount + 1
                                print(string.format("🔄 ИЗМЕНЕНИЕ: %s (pos: %.3f, rot: %.3f)", partName, positionDiff, rotationDiff))
                            end
                        end
                        
                        previousStates[partName] = currentCFrame
                    end
                end
            end
            
            -- Останавливаем через 10 секунд
            if currentTime - startTime > 10 then
                connection:Disconnect()
                print(string.format("\n📊 ИТОГО ИЗМЕНЕНИЙ CFrame: %d", changeCount))
                
                if changeCount == 0 then
                    print("⚠️ CFrame изменений не обнаружено! Питомец статичен.")
                else
                    print("✅ CFrame изменения обнаружены! Питомец анимируется.")
                end
            end
        end)
    end
end

-- 🚀 Создаем GUI для запуска диагностики
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CFrameAnimationDiagnostic"
screenGui.Parent = playerGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 300, 0, 50)
button.Position = UDim2.new(0.5, -150, 0, 200)
button.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
button.Text = "🔍 Диагностика CFrame Анимации"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Font = Enum.Font.SourceSansBold
button.Parent = screenGui

button.MouseButton1Click:Connect(function()
    runDiagnostic()
end)

print("✅ CFrameAnimationDiagnostic готов!")
print("🎯 Возьми Dragonfly в руку, убедись что копия создана, и нажми оранжевую кнопку!")
