-- 🎭 PetScaler CFrame Animation System - FINAL VERSION
-- Интеграция проверенной CFrame системы в PetScaler для копирования анимации питомца

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

print("🎭 === PetScaler CFrame Animation System - FINAL ===")
print("🔄 Система копирования CFrame анимации с питомца в руке на копию")

-- 📊 Конфигурация
local CONFIG = {
    SCALE_FACTOR = 0.3,  -- Масштаб копии
    INTERPOLATION_SPEED = 0.8,  -- Скорость интерполяции CFrame
    HAND_PET_CHECK_INTERVAL = 1.0,  -- Интервал поиска питомца в руке
    DEBUG_INTERVAL = 3.0,  -- Интервал отладочных сообщений
    POSITION_THRESHOLD = 0.001,  -- Минимальное изменение позиции для детекции
    ROTATION_THRESHOLD = 0.001   -- Минимальное изменение поворота для детекции
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

-- 📦 Получение всех анимируемых частей из Tool (включая подмодели)
local function getAnimatedParts(tool)
    local parts = {}
    
    if not tool then return parts end
    
    -- Ищем все BasePart в Tool, включая подмодели (исключая Handle)
    for _, obj in pairs(tool:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "Handle" then
            table.insert(parts, obj)
        end
    end
    
    return parts
end

-- 🎯 Поиск соответствующей части в копии по имени
local function findCorrespondingPart(copyModel, partName)
    for _, obj in pairs(copyModel:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == partName then
            return obj
        end
    end
    return nil
end

-- 📐 Масштабирование CFrame с сохранением поворота
local function scaleCFrame(originalCFrame, scaleFactor)
    local originalPosition = originalCFrame.Position
    local scaledPosition = originalPosition * scaleFactor
    
    -- Сохраняем поворот, но масштабируем позицию
    return CFrame.new(scaledPosition) * (originalCFrame - originalCFrame.Position)
end

-- 🎭 Основная система CFrame анимации для PetScaler
local function startPetScalerCFrameSystem(originalModel, copyModel)
    print("🎭 Запуск PetScaler CFrame Animation System")
    print("📦 Оригинал:", originalModel.Name)
    print("📦 Копия:", copyModel.Name)
    
    -- Убеждаемся что только корневая часть копии заякорена
    local copyRootPart = copyModel.PrimaryPart or copyModel:FindFirstChild("Torso") or copyModel:FindFirstChild("HumanoidRootPart") or copyModel:FindFirstChild("RootPart")
    if copyRootPart then
        copyRootPart.Anchored = true
        print("⚓ Корневая часть копии заякорена:", copyRootPart.Name)
        
        -- Все остальные части должны быть свободными
        for _, part in pairs(copyModel:GetDescendants()) do
            if part:IsA("BasePart") and part ~= copyRootPart then
                part.Anchored = false
            end
        end
        print("🔓 Остальные части копии разъякорены для анимации")
    end
    
    -- Глобальные переменные для системы
    local handPetModel = nil
    local handPetParts = {}
    local lastHandPetCheck = 0
    local previousCFrameStates = {}
    local cframeChangeCount = 0
    local lastChangeTime = 0
    
    local connection = RunService.Heartbeat:Connect(function()
        -- Проверяем существование моделей
        if not originalModel.Parent or not copyModel.Parent then
            print("⚠️ Модель удалена, останавливаю систему")
            connection:Disconnect()
            return
        end
        
        local currentTime = tick()
        
        -- === 🔍 ПОИСК ПИТОМЦА В РУКЕ ===
        if currentTime - lastHandPetCheck >= CONFIG.HAND_PET_CHECK_INTERVAL then
            lastHandPetCheck = currentTime
            
            local foundTool = findHandHeldPet()
            
            if foundTool ~= handPetModel then
                handPetModel = foundTool
                handPetParts = getAnimatedParts(handPetModel)
                
                if handPetModel then
                    print("🎯 ПИТОМЕЦ В РУКЕ НАЙДЕН:", handPetModel.Name)
                    print("🔧 Анимируемых частей:", #handPetParts)
                    
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
        end
        
        -- === 📐 LIVE КОПИРОВАНИЕ CFrame СОСТОЯНИЙ ===
        if handPetModel and #handPetParts > 0 then
            local appliedCount = 0
            local changesDetected = 0
            local debugInfo = {}
            
            -- 🔍 ПРОВЕРКА ANCHORED СОСТОЯНИЙ КОПИИ (раз в 10 секунд)
            if math.floor(currentTime) % 10 == 0 and math.floor(currentTime * 10) % 10 == 0 then
                local anchoredParts = 0
                local totalParts = 0
                for _, part in pairs(copyModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        totalParts = totalParts + 1
                        if part.Anchored then
                            anchoredParts = anchoredParts + 1
                        end
                    end
                end
                print(string.format("⚓ ANCHORED ДИАГНОСТИКА: %d/%d частей заякорено", anchoredParts, totalParts))
            end
            
            -- 📊 ОТСЛЕЖИВАНИЕ И КОПИРОВАНИЕ CFrame ИЗМЕНЕНИЙ
            for _, handPart in ipairs(handPetParts) do
                if handPart and handPart.Parent then
                    local partName = handPart.Name
                    local currentCFrame = handPart.CFrame
                    
                    -- Проверяем изменилось ли CFrame состояние
                    local hasChanged = false
                    if previousCFrameStates[partName] then
                        local prevCFrame = previousCFrameStates[partName]
                        local positionDiff = (currentCFrame.Position - prevCFrame.Position).Magnitude
                        local rotationDiff = math.abs(currentCFrame.LookVector:Dot(prevCFrame.LookVector) - 1)
                        
                        if positionDiff > CONFIG.POSITION_THRESHOLD or rotationDiff > CONFIG.ROTATION_THRESHOLD then
                            hasChanged = true
                            changesDetected = changesDetected + 1
                        end
                    end
                    
                    -- Обновляем предыдущее состояние
                    previousCFrameStates[partName] = currentCFrame
                    
                    -- Находим соответствующую часть в копии и применяем CFrame
                    local copyPart = findCorrespondingPart(copyModel, partName)
                    if copyPart then
                        local success, errorMsg = pcall(function()
                            -- 📐 МАСШТАБИРОВАНИЕ И ПРИМЕНЕНИЕ CFrame
                            local scaledCFrame = scaleCFrame(currentCFrame, CONFIG.SCALE_FACTOR)
                            
                            -- Применяем с интерполяцией для плавности (только к незаякоренным частям)
                            if not copyPart.Anchored then
                                copyPart.CFrame = copyPart.CFrame:Lerp(scaledCFrame, CONFIG.INTERPOLATION_SPEED)
                            end
                            
                            -- Диагностическая информация
                            table.insert(debugInfo, {
                                name = partName,
                                changed = hasChanged,
                                anchored = copyPart.Anchored,
                                applied = not copyPart.Anchored
                            })
                        end)
                        
                        if success then
                            appliedCount = appliedCount + 1
                        else
                            print("❌ Ошибка при применении CFrame", partName, ":", errorMsg)
                        end
                    end
                end
            end
            
            -- Обновляем счетчики изменений
            if changesDetected > 0 then
                cframeChangeCount = cframeChangeCount + changesDetected
                lastChangeTime = currentTime
            end
            
            -- 📊 ДЕТАЛЬНАЯ ДИАГНОСТИКА каждые 3 секунды
            if math.floor(currentTime) % CONFIG.DEBUG_INTERVAL == 0 and math.floor(currentTime * 10) % 10 == 0 then
                print("📐 LIVE CFrame КОПИРОВАНИЕ: применено", appliedCount, "/", #handPetParts, "CFrame состояний")
                
                -- 🎯 ОТЧЕТ ОБ ИЗМЕНЕНИЯХ В ПИТОМЦЕ В РУКЕ
                local timeSinceLastChange = currentTime - lastChangeTime
                print(string.format("🎭 ПИТОМЕЦ В РУКЕ: %d изменений CFrame, последнее %.1f сек назад", 
                    cframeChangeCount, timeSinceLastChange))
                
                if changesDetected > 0 then
                    print(string.format("✅ CFrame АНИМАЦИЯ КОПИРУЕТСЯ: %d частей изменились!", changesDetected))
                else
                    print("⚠️ ПИТОМЕЦ СТАТИЧЕН: CFrame не изменяются")
                end
                
                -- Показываем первые 3 части для диагностики
                for i = 1, math.min(3, #debugInfo) do
                    local info = debugInfo[i]
                    print(string.format("📐 %s: Changed=%s Anchored=%s Applied=%s", 
                        info.name, tostring(info.changed), tostring(info.anchored), tostring(info.applied)))
                end
            end
        else
            -- Питомец в руке не найден - копия остается в текущей позе
            if math.floor(currentTime) % 10 == 0 and math.floor(currentTime * 10) % 10 == 0 then
                print("⏸️ Питомец в руке не найден, копия в статичной позе")
            end
        end
    end)
    
    return connection
end

-- 🚀 Функция для автоматического поиска и запуска системы
local function autoStartPetScaler()
    print("🔍 Автоматический поиск моделей питомцев...")
    
    -- Ищем модели в Workspace
    local pets = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") then
            local hasHead = obj:FindFirstChild("Head")
            local hasTorso = obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso") or obj:FindFirstChild("RootPart")
            
            if (hasHead or hasTorso) and obj.Name ~= character.Name then
                table.insert(pets, obj)
                print("🐕 Найден питомец:", obj.Name)
            end
        end
    end
    
    if #pets >= 2 then
        local originalPet = pets[1]
        local copyPet = pets[2]
        
        print("🎯 Автоматический выбор:")
        print("📦 Оригинал:", originalPet.Name)
        print("📦 Копия:", copyPet.Name)
        
        return startPetScalerCFrameSystem(originalPet, copyPet)
    else
        print("❌ Недостаточно моделей питомцев для автозапуска")
        print("💡 Найдено моделей:", #pets, "| Нужно минимум 2")
        return nil
    end
end

-- 🧪 Функция для ручного запуска (раскомментируй и укажи модели)
local function manualStartPetScaler(originalName, copyName)
    local originalPet = Workspace:FindFirstChild(originalName)
    local copyPet = Workspace:FindFirstChild(copyName)
    
    if originalPet and copyPet then
        print("🎯 Ручной запуск:")
        print("📦 Оригинал:", originalPet.Name)
        print("📦 Копия:", copyPet.Name)
        
        return startPetScalerCFrameSystem(originalPet, copyPet)
    else
        print("❌ Модели не найдены:")
        print("📦 Оригинал найден:", originalPet and "✅" or "❌")
        print("📦 Копия найдена:", copyPet and "✅" or "❌")
        return nil
    end
end

-- 🚀 АВТОМАТИЧЕСКИЙ ЗАПУСК
print("🚀 Попытка автоматического запуска...")
local petScalerConnection = autoStartPetScaler()

if petScalerConnection then
    print("✅ PetScaler CFrame System запущена!")
    print("🎒 Возьми питомца в руки для начала копирования анимации")
    print("🛑 Для остановки: petScalerConnection:Disconnect()")
else
    print("⚠️ Автозапуск не удался")
    print("💡 Для ручного запуска используй: manualStartPetScaler('OriginalName', 'CopyName')")
end

-- Экспорт функций
return {
    startPetScalerCFrameSystem = startPetScalerCFrameSystem,
    autoStartPetScaler = autoStartPetScaler,
    manualStartPetScaler = manualStartPetScaler,
    CONFIG = CONFIG
}

-- 🧪 Пример ручного запуска (раскомментируй и измени имена):
--[[
local connection = manualStartPetScaler("OriginalPetName", "CopyPetName")
if connection then
    print("✅ Система запущена вручную!")
end
--]]
