-- 🔥 PET SCALER v2.0 - Масштабирование с анимацией
-- Объединяет оригинальный PetScaler + SmartMotorCopier
-- Создает масштабированную копию И сразу включает анимацию

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔥 === PET SCALER v2.0 - С АНИМАЦИЕЙ ===")
print("=" .. string.rep("=", 60))

-- Конфигурация (ОБНОВЛЕННАЯ - анимация роста)
local CONFIG = {
    SEARCH_RADIUS = 100,
    START_SCALE = 0.3,      -- Начальный размер (маленький)
    END_SCALE = 1.0,        -- Конечный размер (нормальный)
    TWEEN_TIME = 3.0,       -- Время анимации роста
    EASING_STYLE = Enum.EasingStyle.Quad,
    EASING_DIRECTION = Enum.EasingDirection.Out
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
print("🎯 Радиус поиска:", CONFIG.SEARCH_RADIUS)
print("📏 Анимация роста: от", CONFIG.START_SCALE .. "x до", CONFIG.END_SCALE .. "x")
print("⏱️ Время анимации:", CONFIG.TWEEN_TIME .. " сек")
print()

-- === ФУНКЦИИ ИЗ ОРИГИНАЛЬНОГО PETSCALER ===

-- Функция проверки визуальных элементов питомца (УЛУЧШЕННАЯ ВЕРСИЯ)
local function hasPetVisuals(model)
    local visualCount = 0
    local petVisuals = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        local visualData = nil
        
        -- Проверяем MeshPart (оригинальная логика)
        if obj:IsA("MeshPart") then
            visualCount = visualCount + 1
            visualData = {
                name = obj.Name,
                className = obj.ClassName,
                meshId = obj.MeshId or "",
                type = "MeshPart"
            }
        
        -- Проверяем SpecialMesh (оригинальная логика)
        elseif obj:IsA("SpecialMesh") then
            visualCount = visualCount + 1
            visualData = {
                name = obj.Name,
                className = obj.ClassName,
                meshId = obj.MeshId or "",
                textureId = obj.TextureId or "",
                type = "SpecialMesh"
            }
        
        -- НОВОЕ: Проверяем обычные Part с текстурами/декалями
        elseif obj:IsA("Part") then
            -- Ищем Decal или Texture на Part
            local hasDecal = obj:FindFirstChildOfClass("Decal")
            local hasTexture = obj:FindFirstChildOfClass("Texture")
            
            if hasDecal or hasTexture or obj.Material ~= Enum.Material.Plastic then
                visualCount = visualCount + 1
                visualData = {
                    name = obj.Name,
                    className = obj.ClassName,
                    material = obj.Material.Name,
                    hasDecal = hasDecal ~= nil,
                    hasTexture = hasTexture ~= nil,
                    type = "Part"
                }
            end
        
        -- НОВОЕ: Проверяем UnionOperation (объединенные части)
        elseif obj:IsA("UnionOperation") then
            visualCount = visualCount + 1
            visualData = {
                name = obj.Name,
                className = obj.ClassName,
                type = "UnionOperation"
            }
        
        -- НОВОЕ: Проверяем Attachment с эффектами
        elseif obj:IsA("Attachment") then
            local hasEffect = #obj:GetChildren() > 0
            if hasEffect then
                visualCount = visualCount + 1
                visualData = {
                    name = obj.Name,
                    className = obj.ClassName,
                    effectCount = #obj:GetChildren(),
                    type = "Attachment"
                }
            end
        end
        
        -- Добавляем найденные визуальные элементы
        if visualData then
            table.insert(petVisuals, visualData)
        end
    end
    
    -- Дополнительная проверка: если модель содержит BasePart'ы, считаем её потенциальным питомцем
    if visualCount == 0 then
        local partCount = 0
        for _, obj in pairs(model:GetDescendants()) do
            if obj:IsA("BasePart") then
                partCount = partCount + 1
            end
        end
        
        -- Если есть несколько частей, вероятно это питомец
        if partCount >= 2 then
            visualCount = partCount
            table.insert(petVisuals, {
                name = "BaseParts",
                className = "Multiple",
                partCount = partCount,
                type = "BasePart"
            })
            print("  🔍 Найден потенциальный питомец с " .. partCount .. " частями: " .. model.Name)
        end
    end
    
    return visualCount > 0, petVisuals
end

-- Функция глубокого копирования модели (ОРИГИНАЛЬНАЯ ВЕРСИЯ)
local function deepCopyModel(originalModel)
    print("📋 Создаю глубокую копию модели:", originalModel.Name)
    
    local copy = originalModel:Clone()
    copy.Name = originalModel.Name .. "_SCALED_COPY"
    copy.Parent = Workspace
    
    -- Позиционирование копии (оригинальная логика)
    if copy.PrimaryPart and originalModel.PrimaryPart then
        local originalCFrame = originalModel.PrimaryPart.CFrame
        local offset = Vector3.new(15, 0, 0)
        
        local targetPosition = originalCFrame.Position + offset
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {copy, originalModel}
        
        local rayOrigin = Vector3.new(targetPosition.X, targetPosition.Y + 100, targetPosition.Z)
        local rayDirection = Vector3.new(0, -200, 0)
        
        local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        
        if raycastResult then
            local groundY = raycastResult.Position.Y
            local finalPosition = Vector3.new(targetPosition.X, groundY, targetPosition.Z)
            local newCFrame = CFrame.new(finalPosition, originalCFrame.LookVector)
            copy:SetPrimaryPartCFrame(newCFrame)
            print("📍 Копия размещена на земле")
        else
            local newCFrame = originalCFrame + offset
            copy:SetPrimaryPartCFrame(newCFrame)
            print("📍 Копия размещена на уровне оригинала")
        end
    elseif copy:FindFirstChild("RootPart") and originalModel:FindFirstChild("RootPart") then
        local originalPos = originalModel.RootPart.Position
        local offset = Vector3.new(15, 0, 0)
        copy.RootPart.Position = originalPos + offset
        print("📍 Копия размещена через RootPart")
    else
        print("⚠️ Не удалось точно позиционировать копию")
    end
    
    -- ВАЖНО: НЕ устанавливаем Anchored здесь - это сделает SmartAnchoredManagement
    
    print("✅ Копия создана:", copy.Name)
    return copy
end

-- НОВАЯ ФУНКЦИЯ: Создание копии сразу в маленьком размере
local function createSmallCopy(originalModel, startScale)
    print("🐣 Создаю копию сразу в маленьком размере (" .. startScale .. "x)")
    
    -- Создаем обычную копию
    local copy = deepCopyModel(originalModel)
    if not copy then
        return nil
    end
    
    -- Настраиваем Anchored
    local copyParts = getAllParts(copy)
    if not copyParts or #copyParts == 0 then
        print("⚠️ Не удалось получить части копии, но продолжаем...")
        return copy -- Возвращаем копию без настройки Anchored
    end
    smartAnchoredManagement(copyParts)
    
    -- Определяем центр
    local centerCFrame
    if copy.PrimaryPart then
        centerCFrame = copy.PrimaryPart.CFrame
    else
        local success, modelCFrame = pcall(function() return copy:GetModelCFrame() end)
        if success then
            centerCFrame = modelCFrame
        else
            print("❌ Не удалось определить центр копии!")
            return copy -- Возвращаем копию без масштабирования
        end
    end
    
    -- Мгновенно уменьшаем все части до startScale
    for _, part in ipairs(copyParts) do
        local originalSize = part.Size
        local originalCFrame = part.CFrame
        
        -- Уменьшаем размер
        part.Size = originalSize * startScale
        
        -- Пересчитываем позицию относительно центра
        local relativeCFrame = centerCFrame:Inverse() * originalCFrame
        local scaledRelativeCFrame = CFrame.new(relativeCFrame.Position * startScale) * (relativeCFrame - relativeCFrame.Position)
        part.CFrame = centerCFrame * scaledRelativeCFrame
    end
    
    print("✅ Маленькая копия готова!")
    return copy
end

-- === ФУНКЦИИ ИЗ SMARTMOTORCOPIER ===

-- Функция получения всех BasePart из модели
local function getAllParts(model)
    local parts = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        end
    end
    
    return parts
end

-- Функция получения всех Motor6D из модели
local function getMotor6Ds(model)
    local motors = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Motor6D") then
            table.insert(motors, obj)
        end
    end
    
    return motors
end

-- Функция создания карты Motor6D
local function createMotorMap(motors)
    local map = {}
    
    for _, motor in ipairs(motors) do
        local key = motor.Name
        if motor.Part0 then
            key = key .. "_" .. motor.Part0.Name
        end
        if motor.Part1 then
            key = key .. "_" .. motor.Part1.Name
        end
        
        map[key] = motor
    end
    
    return map
end

-- Функция умного управления Anchored (из SmartMotorCopier)
local function smartAnchoredManagement(copyParts)
    print("🧠 Умное управление Anchored...")
    
    -- Находим "корневую" часть
    local rootPart = nil
    local rootCandidates = {"RootPart", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
    
    for _, candidate in ipairs(rootCandidates) do
        for _, part in ipairs(copyParts) do
            if part.Name == candidate then
                rootPart = part
                break
            end
        end
        if rootPart then break end
    end
    
    if not rootPart then
        rootPart = copyParts[1]
        print("  ⚠️ Корневая часть не найдена, использую:", rootPart.Name)
    else
        print("  ✅ Корневая часть:", rootPart.Name)
    end
    
    -- Применяем умный Anchored
    for _, part in ipairs(copyParts) do
        if part == rootPart then
            part.Anchored = true -- Только корень заякорен
        else
            part.Anchored = false -- Остальные могут двигаться
        end
    end
    
    print("  ✅ Anchored настроен: корень заякорен, остальные свободны")
    return rootPart
end

-- Функция копирования состояния Motor6D
local function copyMotorState(originalMotor, copyMotor)
    if not originalMotor or not copyMotor then
        return false
    end
    
    copyMotor.Transform = originalMotor.Transform
    copyMotor.C0 = originalMotor.C0
    copyMotor.C1 = originalMotor.C1
    
    return true
end

-- === ФУНКЦИИ МАСШТАБИРОВАНИЯ (ОРИГИНАЛЬНЫЕ) ===

-- Функция анимации роста модели (ОБНОВЛЕННАЯ: работает с уже уменьшенной моделью)
local function animateModelGrowth(model, startScale, endScale, tweenTime)
    print("🌱 Начинаю анимацию роста модели:", model.Name)
    print("📏 Размер: от " .. startScale .. "x до " .. endScale .. "x")
    
    local parts = getAllParts(model)
    print("🧩 Найдено частей для анимации:", #parts)
    
    if #parts == 0 then
        print("❌ Нет частей для анимации!")
        return false
    end
    
    -- Определяем центр масштабирования
    local centerCFrame
    if model.PrimaryPart then
        centerCFrame = model.PrimaryPart.CFrame
        print("🎯 Центр роста: PrimaryPart (" .. model.PrimaryPart.Name .. ")")
    else
        local success, modelCFrame = pcall(function() return model:GetModelCFrame() end)
        if success then
            centerCFrame = modelCFrame
            print("🎯 Центр роста: Центр модели")
        else
            print("❌ Не удалось определить центр роста!")
            return false
        end
    end
    
    -- Вычисляем целевые размеры (модель уже в маленьком размере)
    local scaleRatio = endScale / startScale -- Коэффициент увеличения
    print("📊 Коэффициент увеличения:", scaleRatio .. "x")
    
    -- Сохраняем текущие данные всех частей (маленький размер)
    local currentData = {}
    for _, part in ipairs(parts) do
        currentData[part] = {
            size = part.Size,
            cframe = part.CFrame
        }
    end
    
    -- Плавно увеличиваем от startScale до endScale
    print("🔼 Плавно увеличиваю от " .. startScale .. "x до " .. endScale .. "x...")
    
    -- Создаем TweenInfo для роста
    local tweenInfo = TweenInfo.new(
        tweenTime,
        CONFIG.EASING_STYLE,
        CONFIG.EASING_DIRECTION,
        0, -- Повторений
        false, -- Обратная анимация
        0 -- Задержка
    )
    
    -- Анимация роста
    local tweens = {}
    local completedTweens = 0
    
    for _, part in ipairs(parts) do
        local currentSize = currentData[part].size
        local currentCFrame = currentData[part].cframe
        
        -- Вычисляем финальный размер (увеличиваем текущий)
        local finalSize = currentSize * scaleRatio
        
        -- Вычисляем финальный CFrame (увеличиваем относительно центра)
        local relativeCFrame = centerCFrame:Inverse() * currentCFrame
        local finalRelativeCFrame = CFrame.new(relativeCFrame.Position * scaleRatio) * (relativeCFrame - relativeCFrame.Position)
        local finalCFrame = centerCFrame * finalRelativeCFrame
        
        -- Создаем твин роста
        local tween = TweenService:Create(part, tweenInfo, {
            Size = finalSize,
            CFrame = finalCFrame
        })
        
        -- Обработчик завершения
        tween.Completed:Connect(function()
            completedTweens = completedTweens + 1
            if completedTweens == #parts then
                print("✅ Анимация роста завершена!")
                print("🎉 Питомец вырос от " .. startScale .. "x до " .. endScale .. "x размера")
            end
        end)
        
        table.insert(tweens, tween)
        tween:Play()
    end
    
    print("🚀 Запущено " .. #tweens .. " твинов роста")
    return true
end

-- === ФУНКЦИЯ ЗАПУСКА ЖИВОГО КОПИРОВАНИЯ ===

local function startLiveMotorCopying(original, copy)
    print("🔄 Запуск живого копирования Motor6D...")
    
    local originalMotors = getMotor6Ds(original)
    local copyMotors = getMotor6Ds(copy)
    
    print("  Motor6D - Оригинал:", #originalMotors, "Копия:", #copyMotors)
    
    if #originalMotors == 0 or #copyMotors == 0 then
        print("❌ Недостаточно Motor6D для копирования")
        return nil
    end
    
    local originalMap = createMotorMap(originalMotors)
    local copyMap = createMotorMap(copyMotors)
    
    local connection = nil
    local isRunning = true
    local frameCount = 0
    
    connection = RunService.Heartbeat:Connect(function()
        if not isRunning then
            connection:Disconnect()
            return
        end
        
        frameCount = frameCount + 1
        
        -- Проверяем существование моделей
        if not original.Parent or not copy.Parent then
            print("⚠️ Модель удалена, останавливаю копирование")
            isRunning = false
            return
        end
        
        -- Копируем состояния Motor6D
        for key, originalMotor in pairs(originalMap) do
            local copyMotor = copyMap[key]
            if copyMotor and originalMotor.Parent then
                copyMotorState(originalMotor, copyMotor)
            end
        end
        
        -- Статус каждые 3 секунды
        if frameCount % 180 == 0 then
            print("📊 Живое копирование активно (кадр " .. frameCount .. ")")
        end
    end)
    
    print("✅ Живое копирование Motor6D запущено!")
    print("💡 Копия будет повторять движения оригинала")
    
    return connection
end

-- === ОСНОВНЫЕ ФУНКЦИИ ===

-- Функция поиска и масштабирования (из оригинального PetScaler)
local function findAndScalePet()
    print("🔍 Поиск UUID моделей питомцев...")
    
    local foundPets = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
            local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
            if success then
                local distance = (modelCFrame.Position - playerPos).Magnitude
                if distance <= CONFIG.SEARCH_RADIUS then
                    local hasVisuals, meshes = hasPetVisuals(obj)
                    if hasVisuals then
                        table.insert(foundPets, {
                            model = obj,
                            distance = distance,
                            meshes = meshes
                        })
                    end
                end
            end
        end
    end
    
    if #foundPets == 0 then
        print("❌ Питомцы не найдены!")
        return nil
    end
    
    local targetPet = foundPets[1]
    print("🎯 Выбран питомец:", targetPet.model.Name)
    
    return targetPet.model
end

-- Главная функция v2.0 (ОБНОВЛЕННАЯ ЛОГИКА)
local function main()
    print("🚀 PetScaler v2.0 запущен!")
    
    -- Шаг 1: Найти питомца
    local petModel = findAndScalePet()
    if not petModel then
        return
    end
    
    -- Шаг 2: Создать маленькую копию сразу (НОВАЯ ЛОГИКА)
    print("\n🐣 === СОЗДАНИЕ МАЛЕНЬКОЙ КОПИИ ===")
    local petCopy = createSmallCopy(petModel, CONFIG.START_SCALE)
    if not petCopy then
        print("❌ Не удалось создать маленькую копию!")
        return
    end
    
    -- Проверяем, что копия существует и находится в Workspace
    if not petCopy or not petCopy.Parent then
        print("❌ Копия недоступна!")
        return
    end
    
    -- Шаг 3: Сразу запускаем живое копирование анимации (КЛЮЧЕВОЕ ИЗМЕНЕНИЕ!)
    print("\n🔄 === ЗАПУСК ЖИВОЙ АНИМАЦИИ ===")
    local animationConnection = nil
    
    -- Проверяем, что обе модели существуют
    if petModel and petModel.Parent and petCopy and petCopy.Parent then
        animationConnection = startLiveMotorCopying(petModel, petCopy)
    end
    
    if not animationConnection then
        print("⚠️ Живая анимация не запустилась, но продолжаем...")
    else
        print("✅ Живая анимация запущена! Питомец уже двигается!")
    end
    
    -- Шаг 4: Одновременно запускаем анимацию роста
    print("\n🌱 === АНИМАЦИЯ РОСТА ===")
    wait(0.3) -- Короткая пауза чтобы увидеть маленького питомца
    
    -- Проверяем, что копия все еще существует
    if not petCopy or not petCopy.Parent then
        print("❌ Копия исчезла перед анимацией роста!")
        return
    end
    
    local growthSuccess = animateModelGrowth(petCopy, CONFIG.START_SCALE, CONFIG.END_SCALE, CONFIG.TWEEN_TIME)
    
    if not growthSuccess then
        print("❌ Анимация роста не удалась!")
        return
    end
    
    -- Завершение
    print("\n🎉 === УСПЕХ! ===")
    print("✅ Маленькая копия создана")
    print("✅ Живая анимация запущена сразу")
    print("✅ Анимация роста запущена")
    print("💡 Питомец должен сразу двигаться и расти!")
end

-- Создание GUI
local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    local oldGui = playerGui:FindFirstChild("PetScalerV2GUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetScalerV2GUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 250, 0, 80)
    frame.Position = UDim2.new(0, 50, 0, 150) -- Под оригинальным PetScaler
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 255, 0) -- Зеленая рамка
    frame.Parent = screenGui
    
    local button = Instance.new("TextButton")
    button.Name = "ScaleButton"
    button.Size = UDim2.new(0, 230, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    button.BorderSizePixel = 0
    button.Text = "🔥 PetScaler v2.0 + Анимация"
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ Создаю с анимацией..."
        button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        spawn(function()
            local success, errorMsg = pcall(function()
                main()
            end)
            
            if success then
                wait(3)
                button.Text = "🔥 PetScaler v2.0 + Анимация"
                button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            else
                print("❌ Ошибка в main():", errorMsg)
                button.Text = "❌ Ошибка! Попробуйте снова"
                button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            end
        end)
    end)
    
    button.MouseEnter:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(0, 255, 0) then
            button.BackgroundColor3 = Color3.fromRGB(0, 220, 0)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(0, 220, 0) then
            button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        end
    end)
    
    print("🖥️ PetScaler v2.0 GUI создан!")
end

-- Запуск
createGUI()
print("=" .. string.rep("=", 60))
print("💡 PETSCALER v2.0 - ВСЕ В ОДНОМ:")
print("   1. Создает масштабированную копию")
print("   2. Настраивает правильные Anchored состояния")
print("   3. Автоматически запускает живое копирование анимации")
print("🎯 Нажмите зеленую кнопку для запуска!")
print("=" .. string.rep("=", 60))
