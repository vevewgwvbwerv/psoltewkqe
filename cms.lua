-- 🧪 CFrame Animation Tester - Автономный тестер CFrame анимации
-- Автоматически находит питомцов в Workspace и тестирует CFrame анимацию

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

print("🧪 === CFrame Animation Tester - АВТОНОМНЫЙ РЕЖИМ ===")
print("🔍 Автоматический поиск и тестирование CFrame анимации")

-- 📊 Конфигурация
local CONFIG = {
    SCALE_FACTOR = 0.3,
    INTERPOLATION_SPEED = 0.7,
    DEBUG_INTERVAL = 2.0  -- Более частые отчеты для тестирования
}

-- 🔍 Функция поиска питомца в руке
local function findHandHeldPet()
    if not character then return nil end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "%[") and string.find(tool.Name, "KG%]") then
            return tool
        end
    end
    return nil
end

-- 📦 Получение всех анимируемых частей из модели питомца
local function getAnimatedParts(model)
    local parts = {}
    
    if not model then return parts end
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "Handle" then
            table.insert(parts, obj)
        end
    end
    
    return parts
end

-- 🎯 Автоматический поиск моделей питомцев в Workspace
local function findPetModels()
    local pets = {}
    
    -- Ищем модели которые могут быть питомцами
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") then
            -- Проверяем есть ли в модели части похожие на питомца
            local hasHead = obj:FindFirstChild("Head")
            local hasTorso = obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
            local hasHumanoid = obj:FindFirstChild("Humanoid")
            
            if (hasHead or hasTorso) and obj.Name ~= character.Name then
                table.insert(pets, obj)
                print("🐕 Найден потенциальный питомец:", obj.Name)
            end
        end
    end
    
    return pets
end

-- 🧪 Основная функция тестирования CFrame анимации
local function startCFrameTest()
    print("🚀 Запуск CFrame Animation Test")
    
    -- Глобальные переменные
    local handPetModel = nil
    local handPetParts = {}
    local previousCFrameStates = {}
    local cframeChangeCount = 0
    local lastChangeTime = 0
    local testStartTime = tick()
    
    -- Ищем питомцев в мире для справки
    local worldPets = findPetModels()
    print("🌍 Найдено питомцев в мире:", #worldPets)
    
    local connection = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        local testDuration = currentTime - testStartTime
        
        -- === 🔍 ПОИСК ПИТОМЦА В РУКЕ ===
        local foundTool = findHandHeldPet()
        
        if foundTool ~= handPetModel then
            handPetModel = foundTool
            handPetParts = getAnimatedParts(handPetModel)
            
            if handPetModel then
                print("🎯 === НОВЫЙ ПИТОМЕЦ В РУКЕ ОБНАРУЖЕН ===")
                print("Tool:", handPetModel.Name)
                print("🔧 Анимируемых частей:", #handPetParts)
                
                -- Показываем все найденные части
                for i, part in ipairs(handPetParts) do
                    print(string.format("  %d. %s (CFrame: %s)", i, part.Name, tostring(part.CFrame)))
                end
                
                -- Инициализируем отслеживание CFrame
                previousCFrameStates = {}
                for _, part in ipairs(handPetParts) do
                    if part and part.Parent then
                        previousCFrameStates[part.Name] = part.CFrame
                    end
                end
                
                cframeChangeCount = 0
                lastChangeTime = currentTime
            else
                print("⚠️ Питомец в руке не найден")
                handPetParts = {}
            end
        end
        
        -- === 📐 МОНИТОРИНГ CFrame ИЗМЕНЕНИЙ ===
        if handPetModel and #handPetParts > 0 then
            local changesDetected = 0
            local changeDetails = {}
            
            -- Проверяем каждую часть на изменения
            for _, handPart in ipairs(handPetParts) do
                if handPart and handPart.Parent then
                    local partName = handPart.Name
                    local currentCFrame = handPart.CFrame
                    
                    -- Проверяем изменилось ли CFrame состояние
                    if previousCFrameStates[partName] then
                        local prevCFrame = previousCFrameStates[partName]
                        local positionDiff = (currentCFrame.Position - prevCFrame.Position).Magnitude
                        local rotationDiff = math.abs(currentCFrame.LookVector:Dot(prevCFrame.LookVector) - 1)
                        
                        if positionDiff > 0.001 or rotationDiff > 0.001 then
                            changesDetected = changesDetected + 1
                            table.insert(changeDetails, {
                                name = partName,
                                posDiff = positionDiff,
                                rotDiff = rotationDiff
                            })
                        end
                    end
                    
                    -- Обновляем предыдущее состояние
                    previousCFrameStates[partName] = currentCFrame
                end
            end
            
            -- Обновляем счетчики
            if changesDetected > 0 then
                cframeChangeCount = cframeChangeCount + changesDetected
                lastChangeTime = currentTime
            end
            
            -- 📊 ДЕТАЛЬНЫЕ ОТЧЕТЫ каждые 2 секунды
            if math.floor(currentTime) % CONFIG.DEBUG_INTERVAL == 0 and math.floor(currentTime * 10) % 10 == 0 then
                print(string.format("\n📊 === CFrame ТЕСТ ОТЧЕТ (%.1f сек) ===", testDuration))
                print("🎭 Питомец:", handPetModel.Name)
                print("🔧 Частей отслеживается:", #handPetParts)
                print("📐 Изменений в этом кадре:", changesDetected)
                print("🎯 Всего изменений:", cframeChangeCount)
                
                local timeSinceLastChange = currentTime - lastChangeTime
                print(string.format("⏱️ Последнее изменение: %.1f сек назад", timeSinceLastChange))
                
                if changesDetected > 0 then
                    print("✅ CFrame АНИМАЦИЯ АКТИВНА!")
                    
                    -- Показываем детали изменений
                    for i, detail in ipairs(changeDetails) do
                        if i <= 3 then  -- Показываем первые 3
                            print(string.format("  📐 %s: Pos=%.4f Rot=%.4f", 
                                detail.name, detail.posDiff, detail.rotDiff))
                        end
                    end
                else
                    print("⚠️ CFrame НЕ ИЗМЕНЯЮТСЯ")
                end
                
                print("=" .. string.rep("=", 50))
            end
        else
            -- Питомец не найден
            if math.floor(currentTime) % 5 == 0 and math.floor(currentTime * 10) % 10 == 0 then
                print(string.format("🔍 Поиск питомца в руке... (%.1f сек)", testDuration))
                print("💡 Возьми питомца в руки для начала тестирования!")
            end
        end
    end)
    
    print("✅ CFrame Animation Tester запущен!")
    print("🎒 Возьми питомца в руки для начала тестирования")
    print("🛑 Для остановки введи: connection:Disconnect()")
    
    return connection
end

-- 🚀 Автоматический запуск тестера
local testConnection = startCFrameTest()

-- Возвращаем connection для возможности остановки
return testConnection
