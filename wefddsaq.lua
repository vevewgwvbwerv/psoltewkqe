-- 🔥 PET SCALER - ПРОСТАЯ РАБОЧАЯ ВЕРСИЯ С IDLE АНИМАЦИЕЙ
-- Создает масштабированную копию с анимацией + останавливает оригинал в idle позе

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔥 === PET SCALER - ПРОСТАЯ ВЕРСИЯ ===")

-- Конфигурация
local CONFIG = {
    SEARCH_RADIUS = 100,
    SCALE_FACTOR = 3.0,
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
print("📏 Коэффициент увеличения:", CONFIG.SCALE_FACTOR .. "x")

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

-- Функция копирования модели
local function deepCopyModel(originalModel)
    print("📋 Создаю копию модели:", originalModel.Name)
    
    local copy = originalModel:Clone()
    copy.Name = originalModel.Name .. "_SCALED_COPY"
    copy.Parent = Workspace
    
    -- Позиционирование копии
    if copy.PrimaryPart and originalModel.PrimaryPart then
        local originalCFrame = originalModel.PrimaryPart.CFrame
        local offset = Vector3.new(15, 0, 0)
        local newPosition = originalCFrame.Position + offset
        local newCFrame = CFrame.lookAt(newPosition, newPosition + originalCFrame.LookVector, Vector3.new(0, 1, 0))
        copy:SetPrimaryPartCFrame(newCFrame)
    end
    
    print("✅ Копия создана:", copy.Name)
    return copy
end

-- Функция масштабирования
local function scaleModelSmoothly(model, scaleFactor, tweenTime)
    print("🔥 Начинаю масштабирование модели:", model.Name)
    
    local parts = getAllParts(model)
    print("🧩 Найдено частей:", #parts)
    
    if #parts == 0 then
        print("❌ Нет частей для масштабирования!")
        return false
    end
    
    -- Определяем центр масштабирования
    local centerCFrame
    if model.PrimaryPart then
        centerCFrame = model.PrimaryPart.CFrame
    else
        local success, modelCFrame = pcall(function() return model:GetModelCFrame() end)
        if success then
            centerCFrame = modelCFrame
        else
            print("❌ Не удалось определить центр масштабирования!")
            return false
        end
    end
    
    -- Сохраняем исходные данные
    local originalData = {}
    for _, part in ipairs(parts) do
        originalData[part] = {
            size = part.Size,
            cframe = part.CFrame
        }
    end
    
    -- Создаем TweenInfo
    local tweenInfo = TweenInfo.new(
        tweenTime,
        CONFIG.EASING_STYLE,
        CONFIG.EASING_DIRECTION,
        0,
        false,
        0
    )
    
    -- Масштабирование
    local tweens = {}
    local completedTweens = 0
    
    for _, part in ipairs(parts) do
        local originalSize = originalData[part].size
        local originalCFrame = originalData[part].cframe
        
        local newSize = originalSize * scaleFactor
        local relativeCFrame = centerCFrame:Inverse() * originalCFrame
        local scaledRelativeCFrame = CFrame.new(relativeCFrame.Position * scaleFactor) * (relativeCFrame - relativeCFrame.Position)
        local newCFrame = centerCFrame * scaledRelativeCFrame
        
        local tween = TweenService:Create(part, tweenInfo, {
            Size = newSize,
            CFrame = newCFrame
        })
        
        tween.Completed:Connect(function()
            completedTweens = completedTweens + 1
            if completedTweens == #parts then
                print("✅ Масштабирование завершено!")
            end
        end)
        
        table.insert(tweens, tween)
        tween:Play()
    end
    
    return true
end

-- Функция получения Motor6D
local function getMotor6Ds(model)
    local motors = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("Motor6D") then
            local key = obj.Name
            if obj.Part0 then
                key = key .. "_" .. obj.Part0.Name
            end
            if obj.Part1 then
                key = key .. "_" .. obj.Part1.Name
            end
            motors[key] = obj
        end
    end
    return motors
end

-- Функция копирования состояния Motor6D
local function copyMotorState(originalMotor, copyMotor, scaleFactor)
    if not originalMotor or not copyMotor then
        return false
    end
    
    local originalTransform = originalMotor.Transform
    local scaledTransform = CFrame.new(originalTransform.Position * scaleFactor) * (originalTransform - originalTransform.Position)
    copyMotor.Transform = scaledTransform
    
    local originalC0 = originalMotor.C0
    local scaledC0 = CFrame.new(originalC0.Position * scaleFactor) * (originalC0 - originalC0.Position)
    copyMotor.C0 = scaledC0
    
    local originalC1 = originalMotor.C1
    local scaledC1 = CFrame.new(originalC1.Position * scaleFactor) * (originalC1 - originalC1.Position)
    copyMotor.C1 = scaledC1
    
    return true
end

-- Функция настройки Anchored
local function smartAnchoredManagement(copyParts)
    print("🧠 Настройка Anchored...")
    
    local rootPart = nil
    for _, part in ipairs(copyParts) do
        if part.Name == "RootPart" or part.Name == "Torso" or part.Name == "HumanoidRootPart" then
            rootPart = part
            break
        end
    end
    
    if not rootPart and #copyParts > 0 then
        rootPart = copyParts[1]
    end
    
    for _, part in ipairs(copyParts) do
        if part == rootPart then
            part.Anchored = true
        else
            part.Anchored = false
        end
    end
    
    print("✅ Anchored настроен")
    return rootPart
end

-- Функция живого копирования Motor6D
local function startLiveMotorCopying(original, copy)
    print("🔄 Запуск живого копирования Motor6D...")
    
    local originalMotors = getMotor6Ds(original)
    local copyMotors = getMotor6Ds(copy)
    
    if next(originalMotors) == nil or next(copyMotors) == nil then
        print("❌ Motor6D не найдены!")
        return nil
    end
    
    print("✅ Найдено Motor6D - оригинал:", #originalMotors, "копия:", #copyMotors)
    
    local connection = RunService.Heartbeat:Connect(function()
        for key, originalMotor in pairs(originalMotors) do
            local copyMotor = copyMotors[key]
            if copyMotor and originalMotor.Parent then
                copyMotorState(originalMotor, copyMotor, CONFIG.SCALE_FACTOR)
            end
        end
    end)
    
    return connection
end

-- Функция контроля оригинального питомца
local function controlOriginalPet(petModel)
    print("🎯 === КОНТРОЛЬ ОРИГИНАЛЬНОГО ПИТОМЦА ===")
    
    local originalRoot = petModel:FindFirstChild("RootPart") or 
                        petModel:FindFirstChild("Torso") or 
                        petModel:FindFirstChild("HumanoidRootPart")
    
    local originalHumanoid = petModel:FindFirstChildOfClass("Humanoid")
    
    if originalRoot then
        print("🐕 Нашел оригинального питомца:", petModel.Name)
        
        -- Заякориваем корень
        originalRoot.Anchored = true
        print("⚓ Корень заякорен")
        
        -- Отключаем AI
        if originalHumanoid then
            originalHumanoid.WalkSpeed = 0
            originalHumanoid.JumpPower = 0
            print("🤖 AI отключен")
        end
        
        -- Ищем и зацикливаем idle анимацию
        local originalAnimator = petModel:FindFirstChildOfClass("Animator")
        if originalAnimator then
            print("🎭 Нашел Animator - ищу idle анимацию")
            
            local allTracks = originalAnimator:GetPlayingAnimationTracks()
            local idleTrack = nil
            
            for _, track in pairs(allTracks) do
                local trackName = track.Name:lower()
                print("🔍 Анимация:", track.Name)
                
                if trackName:find("idle") or trackName:find("stand") or trackName:find("breath") then
                    idleTrack = track
                    print("✨ Нашел IDLE анимацию:", track.Name)
                elseif trackName:find("walk") or trackName:find("run") or trackName:find("move") then
                    print("🚫 Останавливаю ходьбу:", track.Name)
                    track:Stop()
                end
            end
            
            if idleTrack then
                idleTrack.Looped = true
                idleTrack:Play()
                print("🔄 ЗАЦИКЛИЛ idle анимацию:", idleTrack.Name)
                print("✅ Оригинал будет бесконечно анимироваться idle!")
            else
                print("⚠️ IDLE анимация не найдена")
            end
        else
            print("⚠️ Animator не найден")
        end
        
        print("✅ Оригинал остановлен и настроен на idle!")
    else
        print("❌ Не нашел корень оригинального питомца")
    end
end

-- Основная функция
local function main()
    print("\n🔍 === ПОИСК ПИТОМЦА ===")
    
    local petModel = nil
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= playerChar then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local rootPart = obj:FindFirstChild("RootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local distance = (rootPart.Position - playerPos).Magnitude
                    if distance <= CONFIG.SEARCH_RADIUS then
                        petModel = obj
                        print("🐾 Найден питомец:", obj.Name, "на расстоянии:", math.floor(distance))
                        break
                    end
                end
            end
        end
    end
    
    if not petModel then
        print("❌ Питомец не найден в радиусе", CONFIG.SEARCH_RADIUS)
        return
    end
    
    -- Создаем копию
    print("\n📋 === СОЗДАНИЕ КОПИИ ===")
    local petCopy = deepCopyModel(petModel)
    
    -- Масштабируем с закрепленными частями
    print("\n📏 === МАСШТАБИРОВАНИЕ ===")
    for _, part in pairs(petCopy:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end
    
    wait(0.5)
    local scaleSuccess = scaleModelSmoothly(petCopy, CONFIG.SCALE_FACTOR, CONFIG.TWEEN_TIME)
    
    if not scaleSuccess then
        print("❌ Масштабирование не удалось!")
        return
    end
    
    -- Настраиваем Anchored для анимации
    print("\n🧠 === НАСТРОЙКА ANCHORED ===")
    wait(CONFIG.TWEEN_TIME + 1)
    
    local copyParts = getAllParts(petCopy)
    local rootPart = smartAnchoredManagement(copyParts)
    
    -- Запускаем живое копирование
    print("\n🎭 === ЗАПУСК АНИМАЦИИ ===")
    local connection = startLiveMotorCopying(petModel, petCopy)
    
    -- Контролируем оригинального питомца
    controlOriginalPet(petModel)
    
    if connection then
        print("\n🎉 === ПОЛНЫЙ УСПЕХ! ===")
        print("✅ Масштабированная копия создана")
        print("✅ Анимация запущена")
        print("✅ Оригинальный питомец остановлен")
        print("💡 Копия должна стоять с idle анимацией!")
    else
        print("⚠️ Масштабирование успешно, но анимация не запустилась")
    end
end

-- Создание GUI
local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    local oldGui = playerGui:FindFirstChild("PetScalerSimpleGUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetScalerSimpleGUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 250, 0, 80)
    frame.Position = UDim2.new(0, 50, 0, 250)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 0, 255) -- Фиолетовая рамка
    frame.Parent = screenGui
    
    local button = Instance.new("TextButton")
    button.Name = "ScaleButton"
    button.Size = UDim2.new(0, 230, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    button.BorderSizePixel = 0
    button.Text = "🔥 PetScaler ПРОСТОЙ + IDLE"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ Создаю с idle анимацией..."
        button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        spawn(function()
            main()
            
            wait(3)
            button.Text = "🔥 PetScaler ПРОСТОЙ + IDLE"
            button.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
        end)
    end)
    
    print("🖥️ PetScaler ПРОСТОЙ GUI создан!")
end

-- Запуск
createGUI()
print("💡 Нажмите ФИОЛЕТОВУЮ кнопку для запуска простой версии!")
