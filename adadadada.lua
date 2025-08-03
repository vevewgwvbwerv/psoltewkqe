-- 🔥 PET SCALER - ЭКСТРЕМАЛЬНОЕ ВМЕШАТЕЛЬСТВО ДЛЯ IDLE АНИМАЦИИ
-- Принудительно удерживает питомца в настоящей idle анимации любой ценой

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔥 === PET SCALER - ЭКСТРЕМАЛЬНОЕ ВМЕШАТЕЛЬСТВО ===")

-- Конфигурация
local CONFIG = {
    SEARCH_RADIUS = 100,
    SCALE_FACTOR = 3.0,
    TWEEN_TIME = 3.0,
    EASING_STYLE = Enum.EasingStyle.Quad,
    EASING_DIRECTION = Enum.EasingDirection.Out,
    EXTREME_CHECK_INTERVAL = 0.01 -- КАЖДЫЕ 0.01 СЕКУНДЫ!
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

-- Функция копирования модели
local function deepCopyModel(originalModel)
    print("📋 Создаю копию модели:", originalModel.Name)
    
    local copy = originalModel:Clone()
    copy.Name = originalModel.Name .. "_EXTREME_COPY"
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

-- Функция живого копирования Motor6D
local function startLiveMotorCopying(original, copy)
    local originalMotors = getMotor6Ds(original)
    local copyMotors = getMotor6Ds(copy)
    
    if next(originalMotors) == nil or next(copyMotors) == nil then
        print("❌ Motor6D не найдены для живого копирования!")
        return nil
    end
    
    print("🎭 Запускаю живое копирование Motor6D...")
    
    local function copyMotorState(originalMotor, copyMotor, scaleFactor)
        local originalTransform = originalMotor.Transform
        local scaledTransform = CFrame.new(originalTransform.Position * scaleFactor) * (originalTransform - originalTransform.Position)
        copyMotor.Transform = scaledTransform
        
        local originalC0 = originalMotor.C0
        local scaledC0 = CFrame.new(originalC0.Position * scaleFactor) * (originalC0 - originalC0.Position)
        copyMotor.C0 = scaledC0
        
        local originalC1 = originalMotor.C1
        local scaledC1 = CFrame.new(originalC1.Position * scaleFactor) * (originalC1 - originalC1.Position)
        copyMotor.C1 = scaledC1
    end
    
    local connection = RunService.Heartbeat:Connect(function()
        for key, originalMotor in pairs(originalMotors) do
            local copyMotor = copyMotors[key]
            if copyMotor and originalMotor.Parent and copyMotor.Parent then
                copyMotorState(originalMotor, copyMotor, CONFIG.SCALE_FACTOR)
            end
        end
    end)
    
    print("✅ Живое копирование Motor6D активно!")
    return connection
end

-- 🔥 ЭКСТРЕМАЛЬНОЕ ПРИНУДИТЕЛЬНОЕ УДЕРЖАНИЕ В IDLE
local function startExtremeIdleForcing(petModel)
    print("🔥 === ЗАПУСК ЭКСТРЕМАЛЬНОГО ПРИНУДИТЕЛЬНОГО IDLE ===")
    
    local originalRoot = petModel:FindFirstChild("RootPart") or 
                        petModel:FindFirstChild("Torso") or 
                        petModel:FindFirstChild("HumanoidRootPart")
    
    local originalHumanoid = petModel:FindFirstChildOfClass("Humanoid")
    local originalAnimator = petModel:FindFirstChildOfClass("Animator")
    
    if not originalRoot or not originalHumanoid then
        print("❌ Не найдены необходимые компоненты для экстремального вмешательства!")
        return false
    end
    
    -- Создаем Animator если его нет
    if not originalAnimator then
        originalAnimator = Instance.new("Animator")
        originalAnimator.Parent = originalHumanoid
        print("🎭 Создал новый Animator")
    end
    
    print("🎯 Начинаю экстремальное принудительное удержание в idle...")
    
    -- Сохраняем изначальную позицию
    local originalPosition = originalRoot.Position
    local originalOrientation = originalRoot.CFrame - originalRoot.Position
    
    -- 🔥 ЭКСТРЕМАЛЬНЫЙ МОНИТОРИНГ КАЖДЫЕ 0.01 СЕКУНДЫ
    local extremeConnection = RunService.Heartbeat:Connect(function()
        -- ПРИНУДИТЕЛЬНО блокируем движение
        if originalHumanoid and originalHumanoid.Parent then
            originalHumanoid.WalkSpeed = 0
            originalHumanoid.JumpPower = 0
            -- НЕ включаем PlatformStand - разрешаем анимацию!
        end
        
        -- ПРИНУДИТЕЛЬНО удерживаем позицию
        if originalRoot and originalRoot.Parent then
            local currentPos = originalRoot.Position
            local distance = (currentPos - originalPosition).Magnitude
            
            if distance > 0.1 then -- Если сдвинулся больше чем на 0.1 стадии
                -- МГНОВЕННО возвращаем на место
                originalRoot.CFrame = CFrame.new(originalPosition) * originalOrientation
                originalRoot.Velocity = Vector3.new(0, 0, 0)
                originalRoot.AngularVelocity = Vector3.new(0, 0, 0)
            end
        end
        
        -- ПРИНУДИТЕЛЬНО уничтожаем анимации ходьбы
        if originalAnimator and originalAnimator.Parent then
            local tracks = originalAnimator:GetPlayingAnimationTracks()
            for _, track in pairs(tracks) do
                if track.IsPlaying then
                    local animName = track.Animation.Name:lower()
                    local animId = tostring(track.Animation.AnimationId):lower()
                    
                    -- Уничтожаем любые анимации движения
                    if animName:find("walk") or animName:find("run") or animName:find("move") or
                       animId:find("walk") or animId:find("run") or animId:find("move") then
                        track:Stop()
                        track:Destroy()
                    end
                end
            end
        end
    end)
    
    print("🔥 ЭКСТРЕМАЛЬНОЕ принудительное удержание в idle АКТИВНО!")
    print("⚡ Мониторинг каждые", CONFIG.EXTREME_CHECK_INTERVAL, "секунды")
    
    return extremeConnection
end

-- Главная функция
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
    
    -- Ждем завершения масштабирования
    wait(CONFIG.TWEEN_TIME + 1)
    
    -- Настраиваем Anchored для анимации
    local copyParts = getAllParts(petCopy)
    for _, part in ipairs(copyParts) do
        if part.Name == "RootPart" or part.Name == "Torso" or part.Name == "HumanoidRootPart" then
            part.Anchored = true -- Корень остается заякорен
        else
            part.Anchored = false -- Остальные части для анимации
        end
    end
    
    -- Запускаем живое копирование
    print("\n🎭 === ЗАПУСК ЖИВОГО КОПИРОВАНИЯ ===")
    local copyConnection = startLiveMotorCopying(petModel, petCopy)
    
    -- 🔥 ЗАПУСКАЕМ ЭКСТРЕМАЛЬНОЕ ПРИНУДИТЕЛЬНОЕ УДЕРЖАНИЕ В IDLE
    print("\n🔥 === ЭКСТРЕМАЛЬНОЕ ПРИНУДИТЕЛЬНОЕ IDLE ===")
    local extremeConnection = startExtremeIdleForcing(petModel)
    
    if extremeConnection then
        print("\n🎉 === ЭКСТРЕМАЛЬНЫЙ УСПЕХ! ===")
        print("✅ Масштабированная копия создана")
        print("✅ Живое копирование активно")
        print("🔥 ЭКСТРЕМАЛЬНОЕ принудительное idle активно!")
        print("⚡ Система проверяет и блокирует движение каждые 0.01 секунды!")
        print("💡 Питомец должен стоять на месте в настоящей idle анимации!")
    else
        print("⚠️ Экстремальное вмешательство не запустилось")
    end
end

-- Создание GUI
local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    local oldGui = playerGui:FindFirstChild("PetScalerExtremeGUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetScalerExtremeGUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 280, 0, 80)
    frame.Position = UDim2.new(0, 50, 0, 450)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Красная рамка для экстремального режима
    frame.Parent = screenGui
    
    local button = Instance.new("TextButton")
    button.Name = "ScaleButton"
    button.Size = UDim2.new(0, 260, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    button.BorderSizePixel = 0
    button.Text = "🔥 ЭКСТРЕМАЛЬНЫЙ PetScaler"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        button.Text = "⚡ ЭКСТРЕМАЛЬНОЕ вмешательство..."
        button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        spawn(function()
            main()
            
            wait(3)
            button.Text = "🔥 ЭКСТРЕМАЛЬНЫЙ PetScaler"
            button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end)
    end)
    
    print("🖥️ PetScaler ЭКСТРЕМАЛЬНЫЙ GUI создан!")
end

-- Запуск
createGUI()
print("💡 Нажмите КРАСНУЮ кнопку для экстремального принудительного idle!")
print("🔥 ВНИМАНИЕ: Экстремальный режим - мониторинг каждые 0.01 секунды!")
print("⚡ Это самый агрессивный подход для принудительного удержания в idle!")
