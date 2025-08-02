--[[
    NEARBY PET SCANNER
    Находит питомца рядом с игроком и копирует его
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

print("🔍 Nearby Pet Scanner загружен!")

-- Простой GUI с кнопкой
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NearbyPetScanner"
screenGui.Parent = CoreGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0, 10, 0, 490)
button.BackgroundColor3 = Color3.new(0, 0.5, 1)
button.Text = "🔍 SCAN NEARBY PET"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.Parent = screenGui

-- Функция поиска ближайшего питомца
local function findNearbyPet()
    print("\n🔍 === ПОИСК БЛИЖАЙШЕГО ПИТОМЦА ===")
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        print("❌ Character не найден!")
        return nil
    end
    
    local playerPosition = player.Character.HumanoidRootPart.Position
    print("📍 Позиция игрока: " .. tostring(playerPosition))
    
    local closestPet = nil
    local closestDistance = math.huge
    
    -- Сканируем ВСЕ модели в Workspace
    for _, child in pairs(Workspace:GetChildren()) do
        if child:IsA("Model") and child ~= player.Character then
            
            -- Проверяем есть ли у модели части
            local hasParts = false
            local modelCenter = nil
            
            for _, part in pairs(child:GetChildren()) do
                if part:IsA("BasePart") then
                    hasParts = true
                    if not modelCenter then
                        modelCenter = part.Position
                    end
                    break
                end
            end
            
            if hasParts and modelCenter then
                local distance = (modelCenter - playerPosition).Magnitude
                
                -- Ищем модели в радиусе 50 единиц
                if distance < 50 then
                    print("🐾 Найдена модель: " .. child.Name .. " (расстояние: " .. string.format("%.1f", distance) .. ")")
                    
                    -- Показываем структуру модели
                    local partCount = 0
                    for _, part in pairs(child:GetChildren()) do
                        if part:IsA("BasePart") then
                            partCount = partCount + 1
                            if partCount <= 3 then  -- Показываем только первые 3 части
                                print("  📦 " .. part.Name .. " (Size: " .. tostring(part.Size) .. ")")
                            end
                        end
                    end
                    print("  📊 Всего частей: " .. partCount)
                    
                    -- Выбираем ближайшую модель с наибольшим количеством частей
                    if distance < closestDistance and partCount > 1 then
                        closestDistance = distance
                        closestPet = child
                    end
                end
            end
        end
    end
    
    if closestPet then
        print("✅ Выбран ближайший питомец: " .. closestPet.Name)
        print("📏 Расстояние: " .. string.format("%.1f", closestDistance) .. " единиц")
        return closestPet
    else
        print("❌ Питомец рядом не найден!")
        print("💡 Попробуй:")
        print("  1. Подойди ближе к питомцу")
        print("  2. Выпусти питомца из Tool")
        print("  3. Повтори сканирование")
        return nil
    end
end

-- Функция анимации найденного питомца
local function animateNearbyPet()
    print("\n🎯 === АНИМАЦИЯ БЛИЖАЙШЕГО ПИТОМЦА ===")
    
    local nearbyPet = findNearbyPet()
    if not nearbyPet then return end
    
    -- Клонируем найденного питомца
    local petClone = nearbyPet:Clone()
    petClone.Name = "NearbyPetClone"
    
    -- Позиционируем клон рядом с игроком
    local playerPos = player.Character.HumanoidRootPart.Position
    local targetPos = playerPos + Vector3.new(3, 5, 0)  -- 3 вправо, 5 вверх
    
    if petClone.PrimaryPart then
        petClone:SetPrimaryPartCFrame(CFrame.new(targetPos))
        print("📍 Позиционировал через PrimaryPart")
    else
        petClone:MoveTo(targetPos)
        print("📍 Позиционировал через MoveTo")
    end
    
    petClone.Parent = Workspace
    print("🌍 Клон добавлен в Workspace")
    
    -- Подготавливаем все части к анимации
    local originalSizes = {}
    local parts = {}
    
    for _, part in pairs(petClone:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(parts, part)
            originalSizes[part] = part.Size
            
            -- Устанавливаем начальные параметры
            part.Size = part.Size / 1.88  -- Маленький размер (как в записи)
            part.Transparency = 0.8       -- Полупрозрачный
            part.Anchored = true          -- Фиксируем
            part.CanCollide = false       -- Убираем коллизию
        end
    end
    
    print("📊 Подготовлено " .. #parts .. " частей к анимации")
    
    -- Ждем 1 секунду
    wait(1)
    print("⏰ Начинаю анимацию роста питомца...")
    
    -- Анимация роста (точно как в записи яйца)
    local steps = 20
    
    for i = 1, steps do
        local progress = i / steps
        local sizeMultiplier = (1/1.88) + ((1 - 1/1.88) * progress)  -- От 1/1.88 до 1
        local transparency = 0.8 - (0.8 * progress)  -- От 0.8 до 0
        
        for _, part in pairs(parts) do
            if part and part.Parent then
                part.Size = originalSizes[part] * sizeMultiplier
                part.Transparency = transparency
            end
        end
        
        if i % 5 == 0 then
            print("🔄 Рост: " .. string.format("%.0f", progress * 100) .. "% (размер: " .. string.format("%.2f", sizeMultiplier) .. "x)")
        end
        
        wait(0.1)
    end
    
    print("✅ Анимация роста завершена!")
    print("🎯 Теперь это НАСТОЯЩИЙ питомец с правильной анимацией!")
    
    -- Ждем 4 секунды (как в оригинале)
    wait(4)
    
    -- Исчезновение
    print("💥 Питомец исчезает...")
    for i = 1, 10 do
        for _, part in pairs(parts) do
            if part and part.Parent then
                part.Transparency = i / 10
            end
        end
        wait(0.1)
    end
    
    petClone:Destroy()
    print("🗑️ Анимация завершена!")
end

-- Обработчик кнопки
button.MouseButton1Click:Connect(function()
    button.Text = "⏳ SCANNING..."
    button.BackgroundColor3 = Color3.new(1, 1, 0)
    
    spawn(function()
        animateNearbyPet()
        
        wait(1)
        button.Text = "🔍 SCAN NEARBY PET"
        button.BackgroundColor3 = Color3.new(0, 0.5, 1)
    end)
end)

print("🎯 Nearby Pet Scanner готов!")
print("📋 1. Подойди к питомцу")
print("📋 2. Нажми SCAN NEARBY PET")
print("📋 3. Смотри на анимацию роста!")
