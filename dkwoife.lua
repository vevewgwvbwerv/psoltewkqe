-- 🥚 EGG INTERCEPTOR v1.0 - ЧАСТЬ 1
-- Перехватывает временную модель из яйца и заменяет на Dragonfly
-- Сохраняет ВСЕ эффекты взрыва и роста, НЕ копирует idle анимацию

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🥚 === EGG INTERCEPTOR v1.0 - ЧАСТЬ 1 ===")
print("=" .. string.rep("=", 60))

-- 📊 КОНФИГУРАЦИЯ
local CONFIG = {
    SEARCH_RADIUS = 100,  -- Радиус поиска Dragonfly рядом с игроком
    MONITOR_DURATION = 30, -- Время мониторинга после EggExplode
    DEBUG_MODE = true     -- Подробные логи
}

-- 🎯 СОСТОЯНИЕ ПЕРЕХВАТЧИКА
local InterceptorState = {
    isActive = false,
    eggExplodeDetected = false,
    dragonflyFound = false,
    dragonflyModel = nil,
    originalPetModel = nil,
    interceptComplete = false
}

-- Получаем позицию игрока
local playerChar = player.Character
if not playerChar then
    print("❌ Персонаж игрока не найден!")
    return
end

local hrp = playerChar:FindFirstChild("HumanoidRootPart")
if not hrp then
    print("❌ HumanoidRootPart не найден!")
    return
end

local playerPos = hrp.Position
print("📍 Позиция игрока:", playerPos)
print("🎯 Радиус поиска Dragonfly:", CONFIG.SEARCH_RADIUS)

-- 🐉 ФУНКЦИЯ ПРОВЕРКИ ЧТО МОДЕЛЬ - DRAGONFLY
-- Основана на диагностике: 0 MeshPart, но есть BasePart с характерными именами
local function checkIfDragonfly(model)
    if not model or not model:IsA("Model") then
        return false
    end
    
    local meshPartCount = 0
    local basePartCount = 0
    local hasDragonflyParts = false
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("MeshPart") then
            meshPartCount = meshPartCount + 1
        elseif obj:IsA("BasePart") and obj.Name ~= "Handle" then
            basePartCount = basePartCount + 1
            
            -- Проверяем характерные части Dragonfly
            local partName = obj.Name:lower()
            if partName:find("wing") or partName:find("tail") or 
               partName:find("leg") or partName:find("body") or 
               partName:find("head") or partName:find("bug") or
               partName:find("dragon") then
                hasDragonflyParts = true
            end
        end
    end
    
    -- Dragonfly: 0 MeshPart, но есть BasePart с характерными именами
    local isDragonfly = (meshPartCount == 0) and (basePartCount > 0) and hasDragonflyParts
    
    if CONFIG.DEBUG_MODE and isDragonfly then
        print("🐉 Подтверждение Dragonfly:")
        print("   MeshPart: " .. meshPartCount)
        print("   BasePart: " .. basePartCount) 
        print("   Характерные части: " .. tostring(hasDragonflyParts))
    end
    
    return isDragonfly
end

-- 🔍 ФУНКЦИЯ ПОИСКА DRAGONFLY РЯДОМ С ИГРОКОМ
-- Основана на PetScaler_v2.9.lua с учетом особенностей Dragonfly
local function findNearbyDragonfly()
    if CONFIG.DEBUG_MODE then
        print("🔍 Поиск Dragonfly рядом с игроком...")
    end
    
    local foundDragonflyModels = {}
    
    -- Поиск UUID моделей (как в PetScaler_v2.9.lua)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
            local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
            if success then
                local distance = (modelCFrame.Position - playerPos).Magnitude
                if distance <= CONFIG.SEARCH_RADIUS then
                    -- Проверяем что это Dragonfly (0 MeshPart, но есть BasePart)
                    local isDragonfly = checkIfDragonfly(obj)
                    if isDragonfly then
                        table.insert(foundDragonflyModels, {
                            model = obj,
                            distance = distance
                        })
                        if CONFIG.DEBUG_MODE then
                            print("✅ Найден Dragonfly:", obj.Name, "Дистанция:", math.floor(distance))
                        end
                    end
                end
            end
        end
    end
    
    if #foundDragonflyModels == 0 then
        print("❌ Dragonfly не найден рядом с игроком!")
        return nil
    end
    
    -- Возвращаем ближайший
    table.sort(foundDragonflyModels, function(a, b) return a.distance < b.distance end)
    local targetDragonfly = foundDragonflyModels[1].model
    
    print("🐉 Выбран Dragonfly:", targetDragonfly.Name)
    return targetDragonfly
end

-- 🔍 ФУНКЦИЯ ПОИСКА EGGEXPLODE
-- Основана на EggAnimationSourceTracker.lua
local function checkForEggExplode()
    -- Ищем в ReplicatedStorage
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj.Name == "EggExplode" and obj:IsA("Model") then
            return true, obj, "ReplicatedStorage"
        end
    end
    
    -- Ищем в Workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "EggExplode" and obj:IsA("Model") then
            return true, obj, "Workspace"
        end
    end
    
    return false, nil, nil
end

-- 🎯 ФУНКЦИЯ ПОИСКА ВРЕМЕННОЙ МОДЕЛИ В VISUALS
-- Основана на результатах диагностики
local function findTemporaryPetInVisuals()
    local visualsFolder = Workspace:FindFirstChild("Visuals")
    if not visualsFolder then
        return nil
    end
    
    -- Ищем модели питомцев в Visuals
    for _, obj in pairs(visualsFolder:GetChildren()) do
        if obj:IsA("Model") then
            local modelName = obj.Name:lower()
            -- Проверяем известные имена питомцев из диагностики
            if modelName:find("dog") or modelName:find("bunny") or 
               modelName:find("golden") or modelName:find("lab") then
                if CONFIG.DEBUG_MODE then
                    print("🎯 Найдена временная модель в Visuals:", obj.Name)
                end
                return obj
            end
        end
    end
    
    return nil
end

-- 🔄 ФУНКЦИЯ ГЛУБОКОГО КОПИРОВАНИЯ DRAGONFLY
-- Основана на deepCopyModel из PetScaler_v2.9.lua
local function deepCopyDragonfly(originalDragonfly)
    if CONFIG.DEBUG_MODE then
        print("📋 Создаю глубокую копию Dragonfly:", originalDragonfly.Name)
    end
    
    local copy = originalDragonfly:Clone()
    copy.Name = "Dragonfly_EggReplacement"
    
    -- Убеждаемся что копия не имеет родителя пока
    copy.Parent = nil
    
    if CONFIG.DEBUG_MODE then
        print("✅ Копия Dragonfly создана:", copy.Name)
    end
    
    return copy
end

-- 🎯 ФУНКЦИЯ ЗАМЕНЫ ВРЕМЕННОЙ МОДЕЛИ НА DRAGONFLY
-- Ключевая функция перехвата
local function replaceTemporaryModel(originalPetModel, dragonflyReplacement)
    if CONFIG.DEBUG_MODE then
        print("🔄 Начинаю замену модели:")
        print("   Оригинал:", originalPetModel.Name)
        print("   Замена:", dragonflyReplacement.Name)
    end
    
    -- Сохраняем важные параметры оригинальной модели
    local originalParent = originalPetModel.Parent
    local originalCFrame = originalPetModel:GetModelCFrame()
    local originalSize = originalPetModel:GetModelSize()
    
    if CONFIG.DEBUG_MODE then
        print("📍 Параметры оригинала:")
        print("   Parent:", originalParent and originalParent.Name or "nil")
        print("   Position:", originalCFrame.Position)
        print("   Size:", originalSize)
    end
    
    -- Удаляем оригинальную модель
    originalPetModel:Destroy()
    
    -- Размещаем Dragonfly на том же месте
    dragonflyReplacement:SetPrimaryPartCFrame(originalCFrame)
    dragonflyReplacement.Parent = originalParent
    
    if CONFIG.DEBUG_MODE then
        print("✅ Замена завершена! Dragonfly размещен в:", originalParent.Name)
    end
    
    return dragonflyReplacement
end

-- 🎬 ФУНКЦИЯ КОПИРОВАНИЯ ЭФФЕКТОВ (НЕ IDLE АНИМАЦИИ)
-- Копирует все эффекты кроме idle анимации
local function copyNonIdleEffects(fromModel, toModel)
    if CONFIG.DEBUG_MODE then
        print("🎬 Копирование эффектов (исключая idle)...")
    end
    
    -- БЕЗОПАСНОЕ копирование Animator
    local animatorFound = false
    for _, obj in pairs(fromModel:GetDescendants()) do
        if obj:IsA("Animator") then
            local success, animatorCopy = pcall(function()
                return obj:Clone()
            end)
            
            if success and animatorCopy then
                -- Ищем безопасное место для размещения
                local targetHumanoid = toModel:FindFirstChildOfClass("Humanoid")
                
                if targetHumanoid then
                    -- Проверяем что у Humanoid еще нет Animator
                    local existingAnimator = targetHumanoid:FindFirstChildOfClass("Animator")
                    if not existingAnimator then
                        local placeSuccess = pcall(function()
                            animatorCopy.Parent = targetHumanoid
                        end)
                        if placeSuccess then
                            animatorFound = true
                            if CONFIG.DEBUG_MODE then
                                print("✅ Animator безопасно скопирован в Humanoid")
                            end
                        end
                    end
                end
                
                -- Если не удалось поместить в Humanoid, пробуем корень модели
                if not animatorFound then
                    local existingAnimator = toModel:FindFirstChildOfClass("Animator")
                    if not existingAnimator then
                        local placeSuccess = pcall(function()
                            animatorCopy.Parent = toModel
                        end)
                        if placeSuccess then
                            animatorFound = true
                            if CONFIG.DEBUG_MODE then
                                print("✅ Animator безопасно скопирован в корень модели")
                            end
                        end
                    end
                end
                
                -- Если не удалось разместить, просто удаляем копию
                if not animatorFound then
                    animatorCopy:Destroy()
                    if CONFIG.DEBUG_MODE then
                        print("⚠️ Не удалось разместить Animator, пропускаем")
                    end
                end
            end
            break -- Копируем только первый найденный Animator
        end
    end
    
    -- НЕ копируем Motor6D состояния (чтобы не копировать idle)
    -- Эффекты роста и взрыва будут применены игрой автоматически
    
    if CONFIG.DEBUG_MODE then
        print("✅ Эффекты скопированы (idle анимация исключена)")
        print("   Animator скопирован:", animatorFound)
    end
end

-- ⚡ ОСНОВНАЯ ФУНКЦИЯ МОНИТОРИНГА И ПЕРЕХВАТА
local function startEggInterception()
    print("🚀 Запуск системы перехвата яйца...")
    
    -- Шаг 1: Найти Dragonfly рядом с игроком
    local dragonflyModel = findNearbyDragonfly()
    if not dragonflyModel then
        print("❌ Не найден Dragonfly рядом с игроком!")
        return false
    end
    
    InterceptorState.dragonflyModel = dragonflyModel
    InterceptorState.dragonflyFound = true
    print("✅ Dragonfly найден и готов к замене")
    
    -- Шаг 2: Создать копию Dragonfly для замены
    local dragonflyReplacement = deepCopyDragonfly(dragonflyModel)
    
    -- Шаг 3: Запустить мониторинг EggExplode
    InterceptorState.isActive = true
    local startTime = tick()
    
    print("🔍 Мониторинг EggExplode активен. Откройте яйцо!")
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not InterceptorState.isActive then
            connection:Disconnect()
            return
        end
        
        local elapsed = tick() - startTime
        
        -- Таймаут мониторинга
        if elapsed > CONFIG.MONITOR_DURATION then
            print("⏰ Мониторинг завершен по таймауту")
            InterceptorState.isActive = false
            return
        end
        
        -- Проверяем EggExplode
        if not InterceptorState.eggExplodeDetected then
            local found, eggObj, location = checkForEggExplode()
            if found then
                InterceptorState.eggExplodeDetected = true
                print("⚡ EggExplode обнаружен в", location)
                
                -- ЦИКЛИЧЕСКИЙ ПОИСК временной модели в реальном времени
                spawn(function()
                    print("🔍 Начинаю циклический поиск временной модели в Visuals...")
                    
                    local searchAttempts = 0
                    local maxAttempts = 200 -- 20 секунд поиска (200 * 0.1 сек)
                    local temporaryPet = nil
                    
                    -- Циклический поиск каждые 0.1 секунды
                    while searchAttempts < maxAttempts and not temporaryPet do
                        temporaryPet = findTemporaryPetInVisuals()
                        
                        if temporaryPet then
                            print("🎯 Временная модель НАЙДЕНА:", temporaryPet.Name, "(попытка", searchAttempts + 1, ")")
                            break
                        end
                        
                        searchAttempts = searchAttempts + 1
                        if CONFIG.DEBUG_MODE and searchAttempts % 10 == 0 then
                            print("🔍 Поиск продолжается... попытка", searchAttempts, "из", maxAttempts)
                        end
                        
                        wait(0.1) -- Ждем 0.1 секунды перед следующей попыткой
                    end
                    
                    if temporaryPet then
                        print("✅ Временная модель найдена, начинаю замену...")
                        
                        -- Копируем эффекты (НЕ idle)
                        copyNonIdleEffects(temporaryPet, dragonflyReplacement)
                        
                        -- ГЛАВНОЕ: Заменяем временную модель на Dragonfly
                        local replacedModel = replaceTemporaryModel(temporaryPet, dragonflyReplacement)
                        
                        if replacedModel then
                            InterceptorState.interceptComplete = true
                            print("🎉 УСПЕХ! Временная модель заменена на Dragonfly!")
                            print("✅ Dragonfly получит все эффекты роста и взрыва")
                            print("✅ Idle анимация НЕ копируется (как требовалось)")
                        else
                            print("❌ Ошибка при замене модели")
                        end
                    else
                        print("❌ Временная модель НЕ НАЙДЕНА после", maxAttempts, "попыток")
                        print("💡 Попробуйте открыть яйцо сразу после нажатия кнопки")
                    end
                    
                    InterceptorState.isActive = false
                end)
            end
        end
    end)
    
    return true
end

-- 🖥️ СОЗДАНИЕ GUI СИСТЕМЫ
-- Основано на createGUI из PetScaler_v2.9.lua
local function createEggInterceptorGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Удаляем старый GUI если есть
    local oldGui = playerGui:FindFirstChild("EggInterceptorGUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EggInterceptorGUI"
    screenGui.Parent = playerGui
    
    -- Основной фрейм
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 280, 0, 120)
    frame.Position = UDim2.new(0, 50, 0, 250) -- Под PetScaler
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 100, 0) -- Оранжевая рамка
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.Position = UDim2.new(0, 0, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🥚 EGG INTERCEPTOR v1.0"
    titleLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
    titleLabel.TextSize = 12
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = frame
    
    -- Кнопка запуска
    local interceptButton = Instance.new("TextButton")
    interceptButton.Name = "InterceptButton"
    interceptButton.Size = UDim2.new(0, 260, 0, 35)
    interceptButton.Position = UDim2.new(0, 10, 0, 35)
    interceptButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    interceptButton.BorderSizePixel = 0
    interceptButton.Text = "🥚 ЗАПУСТИТЬ ПЕРЕХВАТ ЯЙЦА"
    interceptButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    interceptButton.TextSize = 12
    interceptButton.Font = Enum.Font.SourceSansBold
    interceptButton.Parent = frame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 5)
    buttonCorner.Parent = interceptButton
    
    -- Статусная метка
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 40)
    statusLabel.Position = UDim2.new(0, 10, 0, 75)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "🔍 Найдите Dragonfly рядом и нажмите кнопку"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 10
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextWrapped = true
    statusLabel.TextYAlignment = Enum.TextYAlignment.Top
    statusLabel.Parent = frame
    
    -- Логика кнопки
    interceptButton.MouseButton1Click:Connect(function()
        if InterceptorState.isActive then
            print("⚠️ Перехват уже активен!")
            return
        end
        
        interceptButton.Text = "⏳ ПОИСК DRAGONFLY..."
        interceptButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        statusLabel.Text = "🔍 Ищем Dragonfly рядом с игроком..."
        
        spawn(function()
            local success = startEggInterception()
            
            if success then
                interceptButton.Text = "🎯 МОНИТОРИНГ АКТИВЕН"
                interceptButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                statusLabel.Text = "✅ Dragonfly найден! Откройте яйцо для замены."
                
                -- Ожидаем завершения перехвата
                while InterceptorState.isActive do
                    wait(0.5)
                end
                
                if InterceptorState.interceptComplete then
                    interceptButton.Text = "🎉 ПЕРЕХВАТ УСПЕШЕН!"
                    interceptButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    statusLabel.Text = "🎉 Успех! Временная модель заменена на Dragonfly!"
                else
                    interceptButton.Text = "⏰ ТАЙМАУТ"
                    interceptButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
                    statusLabel.Text = "⏰ Мониторинг завершен по таймауту."
                end
                
                -- Сброс через 5 секунд
                wait(5)
                interceptButton.Text = "🥚 ЗАПУСТИТЬ ПЕРЕХВАТ ЯЙЦА"
                interceptButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
                statusLabel.Text = "🔍 Готов к новому перехвату."
                
                -- Сброс состояния
                InterceptorState = {
                    isActive = false,
                    eggExplodeDetected = false,
                    dragonflyFound = false,
                    dragonflyModel = nil,
                    originalPetModel = nil,
                    interceptComplete = false
                }
            else
                interceptButton.Text = "❌ DRAGONFLY НЕ НАЙДЕН"
                interceptButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                statusLabel.Text = "❌ Dragonfly не найден рядом с игроком!"
                
                wait(3)
                interceptButton.Text = "🥚 ЗАПУСТИТЬ ПЕРЕХВАТ ЯЙЦА"
                interceptButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
                statusLabel.Text = "🔍 Найдите Dragonfly рядом и попробуйте снова."
            end
        end)
    end)
    
    -- Эффекты наведения
    interceptButton.MouseEnter:Connect(function()
        if interceptButton.BackgroundColor3 == Color3.fromRGB(255, 100, 0) then
            interceptButton.BackgroundColor3 = Color3.fromRGB(255, 120, 20)
        end
    end)
    
    interceptButton.MouseLeave:Connect(function()
        if interceptButton.BackgroundColor3 == Color3.fromRGB(255, 120, 20) then
            interceptButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        end
    end)
    
    print("🖥️ EggInterceptor GUI создан!")
end

-- 🚀 ИНИЦИАЛИЗАЦИЯ И ЗАПУСК
local function initializeEggInterceptor()
    print("🚀 === ИНИЦИАЛИЗАЦИЯ EGG INTERCEPTOR v1.0 ===")
    
    -- Создаем GUI
    createEggInterceptorGUI()
    
    print("✅ EGG INTERCEPTOR v1.0 ГОТОВ К РАБОТЕ!")
    print("📋 ИНСТРУКЦИЯ:")
    print("   1. Найдите Dragonfly рядом с собой (UUID имя с {})")
    print("   2. Нажмите кнопку 'ЗАПУСТИТЬ ПЕРЕХВАТ ЯЙЦА'")
    print("   3. Откройте яйцо - временная модель заменится на Dragonfly")
    print("   4. Dragonfly получит ВСЕ эффекты роста и взрыва")
    print("   5. Idle анимация НЕ копируется (остается оригинальная)")
    print("🎯 Готов к перехвату!")
end

-- ✅ ФИНАЛЬНАЯ ЧАСТЬ 3 ЗАГРУЖЕНА
print("✅ ЧАСТЬ 3 ЗАГРУЖЕНА:")
print("   🖥️ GUI система с кнопкой запуска")
print("   📊 Статусные сообщения и индикация")
print("   🎮 Интерактивное управление")
print("   🔄 Автоматический сброс состояния")
print("🎉 === EGG INTERCEPTOR v1.0 ПОЛНОСТЬЮ ГОТОВ! ===")
print("=" .. string.rep("=", 60))

-- 🚀 ЗАПУСК СИСТЕМЫ
initializeEggInterceptor()
