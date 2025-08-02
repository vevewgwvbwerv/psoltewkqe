-- 🔥 PET SCALER - Плавное увеличение питомца с сохранением анимации
-- Находит UUID модель питомца, копирует её и плавно увеличивает

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

print("🔥 === PET SCALER - ПЛАВНОЕ УВЕЛИЧЕНИЕ ПИТОМЦА ===")
print("=" .. string.rep("=", 60))

-- Конфигурация
local CONFIG = {
    SEARCH_RADIUS = 100,
    SCALE_FACTOR = 3.0,  -- Во сколько раз увеличиваем
    TWEEN_TIME = 3.0,    -- Время анимации увеличения (секунды)
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
print("⏱️ Время анимации:", CONFIG.TWEEN_TIME .. " сек")
print()

-- Функция проверки визуальных элементов питомца
local function hasPetVisuals(model)
    local meshCount = 0
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
        end
    end
    
    return meshCount > 0, petMeshes
end

-- Функция глубокого копирования модели (ИСПРАВЛЕНО позиционирование)
local function deepCopyModel(originalModel)
    print("📋 Создаю глубокую копию модели:", originalModel.Name)
    
    local copy = originalModel:Clone()
    copy.Name = originalModel.Name .. "_SCALED_COPY"
    copy.Parent = Workspace
    
    -- ИСПРАВЛЕНО: Правильное позиционирование копии
    if copy.PrimaryPart and originalModel.PrimaryPart then
        local originalCFrame = originalModel.PrimaryPart.CFrame
        local offset = Vector3.new(15, 0, 0) -- 15 единиц в сторону по X
        
        -- Устанавливаем копию на том же уровне Y что и оригинал
        local newCFrame = originalCFrame + offset
        copy:SetPrimaryPartCFrame(newCFrame)
        
        print("📍 Копия размещена рядом с оригиналом")
        print("  Оригинал:", originalCFrame.Position)
        print("  Копия:", newCFrame.Position)
    elseif copy:FindFirstChild("RootPart") and originalModel:FindFirstChild("RootPart") then
        -- Fallback если нет PrimaryPart
        local originalPos = originalModel.RootPart.Position
        local offset = Vector3.new(15, 0, 0)
        copy.RootPart.Position = originalPos + offset
        print("📍 Копия размещена через RootPart")
    else
        print("⚠️ Не удалось точно позиционировать копию")
    end
    
    print("✅ Копия создана:", copy.Name)
    return copy
end

-- Функция получения всех BasePart в модели
local function getAllParts(model)
    local parts = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        end
    end
    return parts
end

-- Функция плавного масштабирования модели (ИСПРАВЛЕНО: через CFrame)
local function scaleModelSmoothly(model, scaleFactor, tweenTime)
    print("🔥 Начинаю плавное масштабирование модели:", model.Name)
    print("📏 Коэффициент:", scaleFactor .. "x")
    print("⏱️ Время:", tweenTime .. " сек")
    
    local parts = getAllParts(model)
    print("🧩 Найдено частей для масштабирования:", #parts)
    
    if #parts == 0 then
        print("❌ Нет частей для масштабирования!")
        return
    end
    
    -- Определяем центр масштабирования
    local centerCFrame
    if model.PrimaryPart then
        centerCFrame = model.PrimaryPart.CFrame
        print("🎯 Центр масштабирования: PrimaryPart (" .. model.PrimaryPart.Name .. ")")
    else
        -- Если нет PrimaryPart, используем центр модели
        local success, modelCFrame = pcall(function() return model:GetModelCFrame() end)
        if success then
            centerCFrame = modelCFrame
            print("🎯 Центр масштабирования: Центр модели")
        else
            print("❌ Не удалось определить центр масштабирования!")
            return
        end
    end
    
    print("📍 Центр масштабирования:", centerCFrame.Position)
    
    -- Сохраняем исходные данные всех частей
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
        0, -- Повторений
        false, -- Обратная анимация
        0 -- Задержка
    )
    
    -- ИСПРАВЛЕНО: Масштабирование через CFrame чтобы части не разлетались
    local tweens = {}
    local completedTweens = 0
    
    for _, part in ipairs(parts) do
        local originalSize = originalData[part].size
        local originalCFrame = originalData[part].cframe
        
        -- Вычисляем новый размер
        local newSize = originalSize * scaleFactor
        
        -- Вычисляем новый CFrame относительно центра
        local relativeCFrame = centerCFrame:Inverse() * originalCFrame
        local scaledRelativeCFrame = CFrame.new(relativeCFrame.Position * scaleFactor) * (relativeCFrame - relativeCFrame.Position)
        local newCFrame = centerCFrame * scaledRelativeCFrame
        
        -- Создаем твин для размера и CFrame
        local tween = TweenService:Create(part, tweenInfo, {
            Size = newSize,
            CFrame = newCFrame
        })
        
        -- Обработчик завершения твина
        tween.Completed:Connect(function()
            completedTweens = completedTweens + 1
            if completedTweens == #parts then
                print("✅ Масштабирование завершено!")
                print("🎉 Все " .. #parts .. " частей успешно увеличены в " .. scaleFactor .. "x")
            end
        end)
        
        table.insert(tweens, tween)
        tween:Play()
    end
    
    print("🚀 Запущено " .. #tweens .. " твинов для плавного масштабирования")
end

-- Основная функция поиска и масштабирования
local function findAndScalePet()
    print("🔍 Поиск UUID моделей питомцев...")
    print("-" .. string.rep("-", 40))
    
    local foundPets = {}
    
    -- Ищем UUID модели в Workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find("%{") and obj.Name:find("%}") then
            local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
            if success then
                local distance = (modelCFrame.Position - playerPos).Magnitude
                if distance <= CONFIG.SEARCH_RADIUS then
                    print("🎯 Найдена UUID модель:", obj.Name)
                    print("📍 Расстояние:", math.floor(distance) .. " единиц")
                    
                    -- Проверяем визуальные элементы
                    local hasVisuals, meshes = hasPetVisuals(obj)
                    if hasVisuals then
                        print("✅ Модель имеет визуальные элементы питомца!")
                        print("🎨 Визуальных элементов:", #meshes)
                        
                        table.insert(foundPets, {
                            model = obj,
                            distance = distance,
                            meshes = meshes
                        })
                    else
                        print("❌ Модель без визуальных элементов питомца")
                    end
                    print()
                end
            end
        end
    end
    
    print("📊 Найдено подходящих питомцев:", #foundPets)
    
    if #foundPets == 0 then
        print("❌ Питомцы с UUID именами и визуальными элементами не найдены!")
        print("💡 Убедитесь что вы рядом с размещенным питомцем")
        return
    end
    
    -- Берем первого найденного питомца
    local targetPet = foundPets[1]
    print("🎯 Выбран питомец для масштабирования:", targetPet.model.Name)
    print("📍 Расстояние:", math.floor(targetPet.distance) .. " единиц")
    print()
    
    return targetPet.model
end

-- Основная функция скрипта
local function main()
    print("🚀 ПетСкалер запущен!")
    print("🔍 Поиск питомца в радиусе " .. CONFIG.SEARCH_RADIUS .. " единиц...")
    
    local petModel = findAndScalePet()
    if not petModel then
        print("❌ Питомец не найден!")
        return
    end
    
    local petCopy = deepCopyModel(petModel)
    if not petCopy then
        print("❌ Не удалось создать копию!")
        return
    end
    
    -- Небольшая задержка перед масштабированием
    wait(0.5)
    
    scaleModelSmoothly(petCopy, CONFIG.SCALE_FACTOR, CONFIG.TWEEN_TIME)
end

-- Создание GUI с кнопкой
local function createGUI()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Создаем ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetScalerGUI"
    screenGui.Parent = playerGui
    
    -- Создаем Frame для кнопки
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 200, 0, 80)
    frame.Position = UDim2.new(0, 50, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 162, 255)
    frame.Parent = screenGui
    
    -- Создаем кнопку
    local button = Instance.new("TextButton")
    button.Name = "ScaleButton"
    button.Size = UDim2.new(0, 180, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    button.BorderSizePixel = 0
    button.Text = "🔥 Увеличить Питомца"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    -- Обработчик нажатия кнопки
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ Обработка..."
        button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        -- Запускаем основную функцию
        spawn(function()
            main()
            
            -- Возвращаем кнопку в исходное состояние
            wait(2)
            button.Text = "🔥 Увеличить Питомца"
            button.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
        end)
    end)
    
    -- Эффект наведения
    button.MouseEnter:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(0, 162, 255) then
            button.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(0, 140, 220) then
            button.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
        end
    end)
    
    print("🖥️ GUI создан! Нажмите кнопку для увеличения питомца")
end

-- Запуск GUI
createGUI()
print("=" .. string.rep("=", 60))
