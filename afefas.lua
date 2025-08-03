-- 🎯 PET SCALER - ПРИНУДИТЕЛЬНАЯ IDLE АНИМАЦИЯ ДЛЯ КОПИИ
-- Записывает idle позы оригинала и принудительно применяет их к копии

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🎯 === PET SCALER - ПРИНУДИТЕЛЬНАЯ IDLE ДЛЯ КОПИИ ===")

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
    copy.Name = originalModel.Name .. "_IDLE_COPY"
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

-- 🎯 НОВАЯ ФУНКЦИЯ: ЗАПИСЬ IDLE ПОЗ
local function recordIdlePoses(original)
    print("📹 Записываю idle позы оригинала...")
    
    local originalMotors = getMotor6Ds(original)
    local idlePoses = {}
    
    -- Заставляем оригинал остановиться
    local originalHumanoid = original:FindFirstChildOfClass("Humanoid")
    if originalHumanoid then
        originalHumanoid.WalkSpeed = 0
        originalHumanoid.JumpPower = 0
        print("🛑 Остановил оригинал для записи idle поз")
    end
    
    -- Ждем чтобы питомец перешел в idle
    wait(3)
    
    -- Записываем idle позы
    for key, motor in pairs(originalMotors) do
        idlePoses[key] = {
            Transform = motor.Transform,
            C0 = motor.C0,
            C1 = motor.C1
        }
    end
    
    print("✅ Записал", #idlePoses, "idle поз")
    return idlePoses
end

-- 🎯 НОВАЯ ФУНКЦИЯ: ПРИНУДИТЕЛЬНОЕ ПРИМЕНЕНИЕ IDLE ПОЗ К КОПИИ
local function forceIdlePosesToCopy(copy, idlePoses, scaleFactor)
    print("🎭 Принудительно применяю idle позы к копии...")
    
    local copyMotors = getMotor6Ds(copy)
    
    -- Настраиваем Anchored для анимации
    local copyParts = getAllParts(copy)
    local rootPart = nil
    
    for _, part in ipairs(copyParts) do
        if part.Name == "RootPart" or part.Name == "Torso" or part.Name == "HumanoidRootPart" then
            rootPart = part
            part.Anchored = true
        else
            part.Anchored = false
        end
    end
    
    print("🧠 Настроил Anchored для анимации")
    
    -- Функция применения idle поз с масштабированием
    local function applyIdlePoses()
        for key, idlePose in pairs(idlePoses) do
            local copyMotor = copyMotors[key]
            if copyMotor then
                -- Масштабируем позы
                local scaledTransform = CFrame.new(idlePose.Transform.Position * scaleFactor) * (idlePose.Transform - idlePose.Transform.Position)
                local scaledC0 = CFrame.new(idlePose.C0.Position * scaleFactor) * (idlePose.C0 - idlePose.C0.Position)
                local scaledC1 = CFrame.new(idlePose.C1.Position * scaleFactor) * (idlePose.C1 - idlePose.C1.Position)
                
                copyMotor.Transform = scaledTransform
                copyMotor.C0 = scaledC0
                copyMotor.C1 = scaledC1
            end
        end
    end
    
    -- Применяем idle позы один раз
    applyIdlePoses()
    print("✅ Применил idle позы к копии")
    
    -- 🔄 ПРИНУДИТЕЛЬНОЕ ЗАЦИКЛИВАНИЕ IDLE ПОЗ
    spawn(function()
        print("🔄 Запускаю принудительное зацикливание idle поз...")
        
        while copy and copy.Parent do
            wait(0.1) -- Каждые 0.1 секунды
            
            -- Принудительно применяем idle позы
            applyIdlePoses()
        end
        
        print("⚠️ Принудительное зацикливание idle остановлено")
    end)
    
    return true
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
    
    -- 📹 ЗАПИСЫВАЕМ IDLE ПОЗЫ
    print("\n📹 === ЗАПИСЬ IDLE ПОЗ ===")
    local idlePoses = recordIdlePoses(petModel)
    
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
    
    -- 🎭 ПРИНУДИТЕЛЬНО ПРИМЕНЯЕМ IDLE ПОЗЫ К КОПИИ
    print("\n🎭 === ПРИМЕНЕНИЕ IDLE ПОЗ ===")
    local idleSuccess = forceIdlePosesToCopy(petCopy, idlePoses, CONFIG.SCALE_FACTOR)
    
    if idleSuccess then
        print("\n🎉 === ПОЛНЫЙ УСПЕХ! ===")
        print("✅ Масштабированная копия создана")
        print("✅ Idle позы записаны и применены")
        print("✅ Копия принудительно анимируется idle!")
        print("💡 Копия должна стоять с idle анимацией независимо от оригинала!")
    else
        print("⚠️ Масштабирование успешно, но idle позы не применились")
    end
end

-- Создание GUI
local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    local oldGui = playerGui:FindFirstChild("PetScalerIdleGUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetScalerIdleGUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 250, 0, 80)
    frame.Position = UDim2.new(0, 50, 0, 350)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 255, 255) -- Голубая рамка
    frame.Parent = screenGui
    
    local button = Instance.new("TextButton")
    button.Name = "ScaleButton"
    button.Size = UDim2.new(0, 230, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    button.BorderSizePixel = 0
    button.Text = "🎯 PetScaler IDLE FORCER"
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ Записываю idle позы..."
        button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        spawn(function()
            main()
            
            wait(3)
            button.Text = "🎯 PetScaler IDLE FORCER"
            button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        end)
    end)
    
    print("🖥️ PetScaler IDLE FORCER GUI создан!")
end

-- Запуск
createGUI()
print("💡 Нажмите ГОЛУБУЮ кнопку для записи idle поз и создания копии!")
print("🎯 Копия будет ПРИНУДИТЕЛЬНО анимироваться idle независимо от оригинала!")
