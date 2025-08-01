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

-- Функция глубокого копирования модели
local function deepCopyModel(originalModel)
    print("📋 Создаю глубокую копию модели:", originalModel.Name)
    
    local copy = originalModel:Clone()
    copy.Name = originalModel.Name .. "_SCALED_COPY"
    copy.Parent = Workspace
    
    -- Смещаем копию рядом с оригиналом
    if copy.PrimaryPart then
        local offset = Vector3.new(10, 0, 0) -- 10 единиц в сторону
        copy:SetPrimaryPartCFrame(originalModel:GetPrimaryPartCFrame() * CFrame.new(offset))
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

-- Функция плавного масштабирования модели
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
    local centerPoint
    if model.PrimaryPart then
        centerPoint = model.PrimaryPart.Position
        print("🎯 Центр масштабирования: PrimaryPart (" .. model.PrimaryPart.Name .. ")")
    else
        -- Если нет PrimaryPart, используем центр модели
        local success, modelCFrame = pcall(function() return model:GetModelCFrame() end)
        if success then
            centerPoint = modelCFrame.Position
            print("🎯 Центр масштабирования: Центр модели")
        else
            print("❌ Не удалось определить центр масштабирования!")
            return
        end
    end
    
    print("📍 Центр масштабирования:", centerPoint)
    
    -- Сохраняем исходные данные всех частей
    local originalData = {}
    for _, part in ipairs(parts) do
        originalData[part] = {
            size = part.Size,
            position = part.Position,
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
    
    -- Создаем и запускаем твины для каждой части
    local tweens = {}
    local completedTweens = 0
    
    for _, part in ipairs(parts) do
        local originalSize = originalData[part].size
        local originalPos = originalData[part].position
        
        -- Вычисляем новый размер
        local newSize = originalSize * scaleFactor
        
        -- Вычисляем новую позицию относительно центра масштабирования
        local offsetFromCenter = originalPos - centerPoint
        local newPosition = centerPoint + (offsetFromCenter * scaleFactor)
        
        -- Создаем твин для размера и позиции
        local tween = TweenService:Create(part, tweenInfo, {
            Size = newSize,
            Position = newPosition
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
    
    -- Создаем копию
    local petCopy = deepCopyModel(targetPet.model)
    
    -- Ждем немного чтобы копия полностью загрузилась
    wait(0.5)
    
    -- Масштабируем копию
    scaleModelSmoothly(petCopy, CONFIG.SCALE_FACTOR, CONFIG.TWEEN_TIME)
end

-- Запуск
print("🚀 Запуск поиска и масштабирования питомца...")
print()

findAndScalePet()

print()
print("🎯 PET SCALER завершен!")
print("=" .. string.rep("=", 60))
