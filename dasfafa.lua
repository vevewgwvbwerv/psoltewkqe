-- 🎭 PetScaler CFrame Animation System v1.0
-- Система копирования анимации питомца через CFrame состояния частей
-- Основано на открытии что анимация питомца в руке работает через прямое изменение CFrame, а не Motor6D

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

print("🎭 === PetScaler CFrame Animation System v1.0 ===")
print("🔍 Система копирования анимации через CFrame состояния частей")

-- 📊 Конфигурация
local CONFIG = {
    SCALE_FACTOR = 0.3,  -- Масштаб копии относительно оригинала
    HAND_PET_CHECK_INTERVAL = 1.0,  -- Интервал поиска питомца в руке (сек)
    INTERPOLATION_SPEED = 0.7,  -- Скорость интерполяции CFrame (0.1-1.0)
    DEBUG_INTERVAL = 3.0  -- Интервал отладочных сообщений (сек)
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
        if obj:IsA("BasePart") and obj.Name ~= "Handle" then  -- Исключаем Handle
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

-- 🎭 Основная система CFrame анимации
local function startCFrameAnimationSystem(originalModel, copyModel)
    print("🎭 Запуск CFrame Animation System")
    print("🔄 Копия будет повторять CFrame анимацию оригинала!")
    
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
                    print("🎯 НАШЛИ ПИТОМЦА В РУКЕ:", handPetModel.Name)
                    print("🔧 Анимируемых частей:", #handPetParts)
                    
                    -- Инициализируем отслеживание CFrame
                    previousCFrameStates = {}
                    for _, part in ipairs(handPetParts) do
                        if part and part.Parent then
                            previousCFrameStates[part.Name] = part.CFrame
                        end
                    end
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
            
            -- 🔍 ПРОВЕРКА ANCHORED СОСТОЯНИЙ КОПИИ (раз в 5 секунд)
            if math.floor(currentTime) % 5 == 0 and math.floor(currentTime * 10) % 10 == 0 then
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
                        
                        if positionDiff > 0.001 or rotationDiff > 0.001 then
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
                            local originalPosition = currentCFrame.Position
                            local scaledPosition = originalPosition * CONFIG.SCALE_FACTOR
                            
                            -- Сохраняем поворот, но масштабируем позицию
                            local scaledCFrame = CFrame.new(scaledPosition) * (currentCFrame - currentCFrame.Position)
                            
                            -- Применяем с интерполяцией для плавности
                            if not copyPart.Anchored then  -- Применяем только к незаякоренным частям
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
                print("📐 LIVE CFrame АНИМАЦИЯ: применено", appliedCount, "/", #handPetParts, "CFrame состояний")
                
                -- 🎯 ОТЧЕТ ОБ ИЗМЕНЕНИЯХ В ПИТОМЦЕ В РУКЕ
                local timeSinceLastChange = currentTime - lastChangeTime
                print(string.format("🎭 ПИТОМЕЦ В РУКЕ: %d изменений CFrame, последнее %.1f сек назад", 
                    cframeChangeCount, timeSinceLastChange))
                
                if changesDetected > 0 then
                    print(string.format("✅ CFrame АНИМАЦИЯ АКТИВНА: %d частей изменились в этом кадре!", changesDetected))
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
            -- Питомец в руке не найден - используем статичную позу
            if math.floor(currentTime) % 10 == 0 and math.floor(currentTime * 10) % 10 == 0 then
                print("⏸️ Питомец в руке не найден, копия в статичной позе")
            end
        end
    end)
    
    return connection
end

-- 🚀 Функция для запуска системы на конкретной паре моделей
local function initializeCFrameSystem(originalModel, copyModel)
    if not originalModel or not copyModel then
        print("❌ Ошибка: не указаны модели для анимации")
        return nil
    end
    
    print("🚀 Инициализация CFrame Animation System")
    print("📦 Оригинал:", originalModel.Name)
    print("📦 Копия:", copyModel.Name)
    
    -- Убеждаемся что только корневая часть копии заякорена
    local copyRootPart = copyModel.PrimaryPart or copyModel:FindFirstChild("Torso") or copyModel:FindFirstChild("HumanoidRootPart")
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
    
    return startCFrameAnimationSystem(originalModel, copyModel)
end

-- Экспорт функций для использования в других скриптах
return {
    initializeCFrameSystem = initializeCFrameSystem,
    startCFrameAnimationSystem = startCFrameAnimationSystem,
    CONFIG = CONFIG
}

-- 🧪 Пример использования (раскомментируй для тестирования):
--[[
-- Найди модели в Workspace
local originalPet = Workspace:FindFirstChild("OriginalPetName")
local copyPet = Workspace:FindFirstChild("CopyPetName")

if originalPet and copyPet then
    local animationSystem = initializeCFrameSystem(originalPet, copyPet)
    print("✅ CFrame Animation System запущена!")
    print("🛑 Для остановки: animationSystem:Disconnect()")
else
    print("❌ Модели не найдены в Workspace")
end
--]]
