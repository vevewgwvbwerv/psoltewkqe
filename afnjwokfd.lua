--[[
    WORKSPACE PET COPIER
    Находит реальные модели питомцев в Workspace и копирует их внешний вид
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

print("🔍 Workspace Pet Copier загружен!")

-- Простой GUI с кнопками
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WorkspacePetCopier"
screenGui.Parent = CoreGui

local scanButton = Instance.new("TextButton")
scanButton.Size = UDim2.new(0, 200, 0, 50)
scanButton.Position = UDim2.new(0, 10, 0, 430)
scanButton.BackgroundColor3 = Color3.new(0, 1, 0)
scanButton.Text = "🔍 SCAN WORKSPACE PETS"
scanButton.TextColor3 = Color3.new(1, 1, 1)
scanButton.TextScaled = true
scanButton.Font = Enum.Font.GothamBold
scanButton.Parent = screenGui

local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0, 200, 0, 50)
copyButton.Position = UDim2.new(0, 220, 0, 430)
copyButton.BackgroundColor3 = Color3.new(1, 0, 0)
copyButton.Text = "🎯 COPY & ANIMATE PET"
copyButton.TextColor3 = Color3.new(1, 1, 1)
copyButton.TextScaled = true
copyButton.Font = Enum.Font.GothamBold
copyButton.Parent = screenGui

local foundPets = {}

-- Функция поиска питомцев в Workspace
local function scanWorkspacePets()
    print("\n🔍 === СКАНИРОВАНИЕ WORKSPACE ===")
    
    foundPets = {}
    
    -- Сканируем весь Workspace
    for _, child in pairs(Workspace:GetChildren()) do
        if child:IsA("Model") then
            local name = child.Name
            
            -- Ищем модели с длинными hex-названиями (как на скриншоте)
            if string.len(name) > 20 and (name:find("-") or name:find("%x%x%x%x")) then
                table.insert(foundPets, child)
                print("🐾 Найден питомец: " .. name)
                
                -- Показываем структуру модели
                print("  📦 Части модели:")
                for _, part in pairs(child:GetChildren()) do
                    if part:IsA("BasePart") then
                        print("    - " .. part.Name .. " (" .. part.ClassName .. ", Size: " .. tostring(part.Size) .. ")")
                    end
                end
            end
        end
    end
    
    print("📊 Найдено питомцев: " .. #foundPets)
    
    if #foundPets == 0 then
        print("❌ Питомцы не найдены! Попробуй:")
        print("  1. Выпусти питомца из Tool (правый клик)")
        print("  2. Подожди пока он появится в мире")
        print("  3. Повтори сканирование")
    else
        print("✅ Питомцы найдены! Можно копировать и анимировать")
    end
end

-- Функция копирования и анимации питомца
local function copyAndAnimatePet()
    print("\n🎯 === КОПИРОВАНИЕ И АНИМАЦИЯ ПИТОМЦА ===")
    
    if #foundPets == 0 then
        print("❌ Сначала просканируй Workspace!")
        return
    end
    
    -- Берем первого найденного питомца
    local originalPet = foundPets[1]
    print("🐾 Копирую питомца: " .. originalPet.Name)
    
    -- Клонируем всю модель питомца
    local petClone = originalPet:Clone()
    petClone.Name = "AnimatedPetClone"
    
    -- Позиционируем клон рядом с игроком
    local playerPos = player.Character.HumanoidRootPart.Position
    local targetPos = playerPos + Vector3.new(5, 3, 0)
    
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
            part.Size = part.Size / 1.88  -- Маленький размер
            part.Transparency = 0.8       -- Полупрозрачный
            part.Anchored = true          -- Фиксируем
            part.CanCollide = false       -- Убираем коллизию
            
            print("  📦 Подготовил: " .. part.Name)
        end
    end
    
    print("📊 Подготовлено " .. #parts .. " частей к анимации")
    
    -- Ждем 1 секунду
    wait(1)
    print("⏰ Начинаю анимацию роста РЕАЛЬНОГО питомца...")
    
    -- Анимация роста всех частей одновременно
    local steps = 20
    
    for i = 1, steps do
        local progress = i / steps
        local sizeMultiplier = (1/1.88) + ((1 - 1/1.88) * progress)
        local transparency = 0.8 - (0.8 * progress)
        
        for _, part in pairs(parts) do
            if part and part.Parent then
                part.Size = originalSizes[part] * sizeMultiplier
                part.Transparency = transparency
            end
        end
        
        if i % 5 == 0 then
            print("🔄 Рост питомца: " .. string.format("%.0f", progress * 100) .. "%")
        end
        
        wait(0.1)
    end
    
    print("✅ Анимация роста завершена!")
    print("🎯 Теперь это НАСТОЯЩИЙ питомец с анимацией!")
    
    -- Ждем 5 секунд для осмотра
    wait(5)
    
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
    print("🗑️ Тест завершен!")
end

-- Обработчики кнопок
scanButton.MouseButton1Click:Connect(function()
    scanButton.Text = "⏳ SCANNING..."
    scanButton.BackgroundColor3 = Color3.new(1, 1, 0)
    
    spawn(function()
        scanWorkspacePets()
        
        wait(1)
        scanButton.Text = "🔍 SCAN WORKSPACE PETS"
        scanButton.BackgroundColor3 = Color3.new(0, 1, 0)
    end)
end)

copyButton.MouseButton1Click:Connect(function()
    copyButton.Text = "⏳ ANIMATING..."
    copyButton.BackgroundColor3 = Color3.new(1, 1, 0)
    
    spawn(function()
        copyAndAnimatePet()
        
        wait(1)
        copyButton.Text = "🎯 COPY & ANIMATE PET"
        copyButton.BackgroundColor3 = Color3.new(1, 0, 0)
    end)
end)

print("🎯 Workspace Pet Copier готов!")
print("📋 Инструкция:")
print("  1. Выпусти питомца в мир (правый клик на Tool)")
print("  2. Нажми SCAN WORKSPACE PETS")
print("  3. Нажми COPY & ANIMATE PET")
print("  4. Смотри на НАСТОЯЩЕГО питомца с анимацией!")
