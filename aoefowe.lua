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

-- Конфигурация (УЛУЧШЕННАЯ: рост с 0.3 до 1.0)
local CONFIG = {
    SEARCH_RADIUS = 100,
    INITIAL_SCALE = 0.3,  -- 🔥 Новое: начальный размер (маленький)
    FINAL_SCALE = 1.0,    -- 🔥 Новое: финальный размер (оригинальный)
    TWEEN_TIME = 3.0,
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
print("🌱 Плавный рост: с", CONFIG.INITIAL_SCALE, "до", CONFIG.FINAL_SCALE)
print("⏱️ Время анимации:", CONFIG.TWEEN_TIME .. " сек")
print()

-- === ФУНКЦИИ ИЗ ОРИГИНАЛЬНОГО PETSCALER ===

-- Функция проверки визуальных элементов питомца (УЛУЧШЕННАЯ ДЛЯ DRAGONFLY!)
local function hasPetVisuals(model)
    local meshCount = 0
    local basepartCount = 0
    local petMeshes = {}
    
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("MeshPart") then
            meshCount = meshCount + 1
            local meshData = {
                name = obj.Name,
                className = obj.ClassName,
                meshId = obj.MeshId or ""
            }
            if meshData.meshId ~= "" then
                table.insert(petMeshes, meshData)
            end
        elseif obj:IsA("SpecialMesh") then
            meshCount = meshCount + 1
            local meshData = {
                name = obj.Name,
                className = obj.ClassName,
                meshId = obj.MeshId or "",
                textureId = obj.TextureId or ""
            }
            if meshData.meshId ~= "" or meshData.textureId ~= "" then
                table.insert(petMeshes, meshData)
            end
        elseif obj:IsA("BasePart") and obj.Name ~= "Handle" then
            -- 🔥 НОВОЕ: Поддержка DRAGONFLY с BasePart (не Handle)
            basepartCount = basepartCount + 1
            
            -- Особое внимание к Dragonfly частям
            local isDragonflyPart = string.find(obj.Name:lower(), "wing") or 
                                  string.find(obj.Name:lower(), "tail") or 
                                  string.find(obj.Name:lower(), "leg") or 
                                  string.find(obj.Name:lower(), "body") or 
                                  string.find(obj.Name:lower(), "head") or 
                                  string.find(obj.Name:lower(), "bug")
            
            if isDragonflyPart then
                local partData = {
                    name = obj.Name,
                    className = obj.ClassName,
                    type = "DragonflyPart"
                }
                table.insert(petMeshes, partData)
            end
        end
    end
    
    -- 🔥 УЛУЧШЕННАЯ ЛОГИКА: Принимаем питомцев с MeshPart ИЛИ BasePart!
    local hasVisuals = meshCount > 0 or basepartCount > 0
    
    if basepartCount > 0 and meshCount == 0 then
        print("🐉 Найден Dragonfly-тип питомец с BasePart (без MeshPart): " .. basepartCount .. " частей")
    end
    
    return hasVisuals, petMeshes
end

-- Функция глубокого копирования модели (ОРИГИНАЛЬНАЯ ВЕРСИЯ)
-- Переписанная функция: копия появляется в позиции eggPetModel, scale берется из eggPetModel, offset и tween убраны
local function deepCopyModel(originalModel, eggPetModel)
    print("📋 Создаю глубокую копию модели:", originalModel.Name)
    
    local copy = originalModel:Clone()
    copy.Name = originalModel.Name .. "_SCALED_COPY"
    copy.Parent = Workspace

    -- Копируем позицию и ориентацию из eggPetModel
    if eggPetModel and eggPetModel.PrimaryPart and copy.PrimaryPart then
        local eggCFrame = eggPetModel.PrimaryPart.CFrame
        copy:SetPrimaryPartCFrame(eggCFrame)
        print("📍 Копия размещена в позиции яйца")
    elseif eggPetModel and eggPetModel:FindFirstChild("RootPart") and copy:FindFirstChild("RootPart") then
        copy.RootPart.CFrame = eggPetModel.RootPart.CFrame
        print("📍 Копия размещена по RootPart яйца")
    else
        print("⚠️ Не удалось точно позиционировать копию, fallback к оригиналу")
        if originalModel.PrimaryPart and copy.PrimaryPart then
            copy:SetPrimaryPartCFrame(originalModel.PrimaryPart.CFrame)
        end
    end

    -- Копируем масштаб (если есть) из eggPetModel
    if eggPetModel and copy then
        for _, part in ipairs(copy:GetDescendants()) do
            if part:IsA("BasePart") then
                local eggPart = eggPetModel:FindFirstChild(part.Name)
                if eggPart and eggPart:IsA("BasePart") then
                    part.Size = eggPart.Size
                    if part:FindFirstChild("SpecialMesh") and eggPart:FindFirstChild("SpecialMesh") then
                        part.SpecialMesh.Scale = eggPart.SpecialMesh.Scale
                    end
                end
            end
        end
        print("📏 Масштаб копии установлен как у яйца")
    end

    print("✅ Копия создана:", copy.Name)
    return copy
end
-- Задел: копирование анимаций будет добавлено отдельно (без idle)

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

-- Функция плавного масштабирования модели (УЛУЧШЕННАЯ: рост с 0.3 до 1.0)
local function scaleModelSmoothly(model)
    print("🔥 Начинаю плавный рост модели:", model.Name)
    print("📊 Рост с", CONFIG.INITIAL_SCALE, "до", CONFIG.FINAL_SCALE, "за", CONFIG.TWEEN_TIME, "сек")
    
    local parts = getAllParts(model)
    print("🧩 Найдено частей для масштабирования:", #parts)
    
    if #parts == 0 then
        print("❌ Нет частей для масштабирования!")
        return false
    end
    
    -- Определяем центр масштабирования
    local centerCFrame
    if model.PrimaryPart then
        centerCFrame = model.PrimaryPart.CFrame
        print("🎯 Центр масштабирования: PrimaryPart (" .. model.PrimaryPart.Name .. ")")
    else
        local success, modelCFrame = pcall(function() return model:GetModelCFrame() end)
        if success then
            centerCFrame = modelCFrame
            print("🎯 Центр масштабирования: Центр модели")
        else
            print("❌ Не удалось определить центр масштабирования!")
            return false
        end
    end
    
    -- 🔥 НОВАЯ ЛОГИКА: Сохраняем ОРИГИНАЛЬНЫЕ размеры и позиции
    local originalData = {}
    for _, part in ipairs(parts) do
        originalData[part] = {
            originalSize = part.Size,  -- 🔥 Оригинальный размер (1.0)
            originalCFrame = part.CFrame -- 🔥 Оригинальная позиция (1.0)
        }
    end
    
    -- 🔥 ШАГ 1: СНАЧАЛА УМЕНЬШАЕМ ДО 0.3 (МГНОВЕННО!)
    print("🔽 Шаг 1: Уменьшаю до", CONFIG.INITIAL_SCALE, "(мгновенно)")
    for _, part in ipairs(parts) do
        local originalSize = originalData[part].originalSize
        local originalCFrame = originalData[part].originalCFrame
        
        -- Вычисляем маленький размер и позицию
        local smallSize = originalSize * CONFIG.INITIAL_SCALE
        local relativeCFrame = centerCFrame:Inverse() * originalCFrame
        local scaledRelativeCFrame = CFrame.new(relativeCFrame.Position * CONFIG.INITIAL_SCALE) * (relativeCFrame - relativeCFrame.Position)
        local smallCFrame = centerCFrame * scaledRelativeCFrame
        
        -- Мгновенно уменьшаем
        part.Size = smallSize
        part.CFrame = smallCFrame
    end
    
    -- 🔥 ШАГ 2: ПЛАВНО УВЕЛИЧИВАЕМ ДО 1.0 (ОРИГИНАЛЬНЫЙ РАЗМЕР!)
    print("🚀 Шаг 2: Плавно увеличиваю до", CONFIG.FINAL_SCALE, "(оригинальный размер)")
    
    -- Создаем TweenInfo
    local tweenInfo = TweenInfo.new(
        CONFIG.TWEEN_TIME,
        CONFIG.EASING_STYLE,
        CONFIG.EASING_DIRECTION,
        0, -- Повторений
        false, -- Обратная анимация
        0 -- Задержка
    )
    
    -- Создаем твины для плавного роста до оригинального размера
    local tweens = {}
    local completedTweens = 0
    
    for _, part in ipairs(parts) do
        local targetSize = originalData[part].originalSize * CONFIG.FINAL_SCALE -- 🔥 Цель: оригинальный размер!
        local targetCFrame = originalData[part].originalCFrame -- 🔥 Цель: оригинальная позиция!
        
        -- Создаем твин для плавного роста
        local tween = TweenService:Create(part, tweenInfo, {
            Size = targetSize,
            CFrame = targetCFrame
        })
        
        -- Обработчик завершения твина
        tween.Completed:Connect(function()
            completedTweens = completedTweens + 1
            if completedTweens == #parts then
                print("✅ Рост завершен!")
                print("🎉 Питомец вырос с " .. CONFIG.INITIAL_SCALE .. " до " .. CONFIG.FINAL_SCALE .. " (оригинальный размер)!")
            end
        end)
        
        table.insert(tweens, tween)
        tween:Play()
    end
    
    print("🚀 Запущено " .. #tweens .. " твинов для плавного роста")
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
-- Новая функция поиска: ищет оригинал и eggPetModel (модель питомца в яйце)
local function findOriginalAndEggPet()
    print("🔍 Поиск оригинального питомца и питомца в яйце...")
    local foundPets = {}
    local foundEggPets = {}

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            -- Оригинал: имя в фигурных скобках и UUID
            if obj.Name:find("%{") and obj.Name:find("%}") then
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
            -- Питомец в яйце: ищем по workspace.visuals, имени без фигурных скобок, или по диагностике
            if obj.Parent and obj.Parent.Name == "visuals" then
                table.insert(foundEggPets, obj)
            end
        end
    end

    if #foundPets == 0 then
        print("❌ Оригинальные питомцы не найдены!")
        return nil, nil
    end
    if #foundEggPets == 0 then
        print("❌ Питомцы в яйце не найдены (workspace.visuals)!")
        return foundPets[1].model, nil
    end

    print("🎯 Выбран оригинал:", foundPets[1].model.Name)
    print("🥚 Найден питомец в яйце:", foundEggPets[1].Name)
    return foundPets[1].model, foundEggPets[1]
end


-- Главная функция v2.0
local function main()
    print("🚀 PetScaler v2.0 запущен!")
    -- Шаг 1: Найти оригинал и eggPetModel
    local petModel, eggPetModel = findOriginalAndEggPet()
    if not petModel then
        return
    end
    -- Шаг 2: Создать копию в позиции и с масштабом как у яйца
    local petCopy = deepCopyModel(petModel, eggPetModel)
    if not petCopy then
        print("❌ Не удалось создать копию!")
        return
    end
    -- Шаг 3: Настроить умный Anchored
    print("\n🧠 === НАСТРОЙКА ANCHORED ===")
    local copyParts = getAllParts(petCopy)
    local rootPart = smartAnchoredManagement(copyParts)
    -- Шаг 4: Удалить оригинал из workspace.visuals, если eggPetModel существует
    if eggPetModel and eggPetModel.Parent then
        print("🗑️ Удаляю оригинал из workspace.visuals:", eggPetModel.Name)
        eggPetModel:Destroy()
    end
    -- Шаг 5: Копирование анимаций (кроме idle)
    print("\n🎭 === КОПИРОВАНИЕ АНИМАЦИЙ ===")
    copyPetAnimations(petModel, petCopy)
    print("✅ Анимации скопированы (кроме idle)")

-- Копирование всех анимаций кроме idle
function copyPetAnimations(original, copy)
    if not original or not copy then
        print("⚠️ Нет оригинала или копии для копирования анимаций")
        return
    end
    -- Копируем все AnimationController/Animator и AnimationTrack кроме idle
    local function isIdleAnimation(anim)
        return anim.Name:lower():find("idle") ~= nil
    end
    -- Найти Animator в оригинале и копии
    local origAnimator = nil
    local copyAnimator = nil
    for _, obj in ipairs(original:GetDescendants()) do
        if obj:IsA("Animator") then origAnimator = obj break end
    end
    for _, obj in ipairs(copy:GetDescendants()) do
        if obj:IsA("Animator") then copyAnimator = obj break end
    end
    if not origAnimator or not copyAnimator then
        print("⚠️ Animator не найден!")
        return
    end
    -- Копируем все AnimationTrack кроме idle
    for _, track in ipairs(origAnimator:GetPlayingAnimationTracks()) do
        if not isIdleAnimation(track.Animation) then
            local newTrack = copyAnimator:LoadAnimation(track.Animation)
            newTrack:Play(0, 1, track.Speed)
            print("🎬 Скопирована анимация:", track.Animation.Name)
        else
            print("⏸️ Пропущена idle-анимация:", track.Animation.Name)
        end
    end
    -- Копируем эффекты (если они реализованы как Animation)
    for _, effect in ipairs(original:GetDescendants()) do
        if effect:IsA("Animation") and not isIdleAnimation(effect) then
            local newTrack = copyAnimator:LoadAnimation(effect)
            newTrack:Play()
            print("💥 Скопирован эффект:", effect.Name)
        end
    end
end

        print("✅ Масштабированная копия создана")
        print("✅ Анимация запущена")
        print("💡 Копия должна повторять движения оригинала!")
    else
        print("⚠️ Масштабирование успешно, но анимация не запустилась")
        print("💡 Возможно проблема с Motor6D соединениями")
    end
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
            main()
            
            wait(3)
            button.Text = "🔥 PetScaler v2.0 + Анимация"
            button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
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
