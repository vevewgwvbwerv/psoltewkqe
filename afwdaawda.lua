--[[
    FINAL WORKING PET ANIMATION
    Копирует найденную модель питомца и показывает анимацию роста
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

print("🎯 Final Working Pet Animation загружен!")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FinalWorkingPetAnimation"
screenGui.Parent = CoreGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0, 10, 0, 10)
button.BackgroundColor3 = Color3.new(0, 1, 0)
button.Text = "🎯 ANIMATE FOUND PET"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.Parent = screenGui

-- Функция поиска питомца по hex-имени
local function findPetModel()
    print("🔍 Ищу модель питомца с hex-именем...")
    
    for _, child in pairs(Workspace:GetChildren()) do
        if child:IsA("Model") then
            local name = child.Name
            
            -- Ищем модели с длинными hex-именами (как bcf2de52-5f25-471d-a535-dc175ea27744)
            if string.len(name) > 30 and name:find("-") and name:find("%x") then
                
                -- Проверяем что у модели есть части питомца
                local hasHead = child:FindFirstChild("Head")
                local hasTorso = child:FindFirstChild("Torso")
                local hasRootPart = child:FindFirstChild("RootPart")
                
                if hasHead and hasTorso then
                    print("✅ Найдена модель питомца: " .. name)
                    
                    -- Показываем все части
                    local partCount = 0
                    for _, part in pairs(child:GetChildren()) do
                        if part:IsA("BasePart") then
                            partCount = partCount + 1
                            print("  📦 " .. part.Name .. " (Size: " .. tostring(part.Size) .. ")")
                        end
                    end
                    
                    print("📊 Всего частей: " .. partCount)
                    return child
                end
            end
        end
    end
    
    print("❌ Модель питомца не найдена!")
    return nil
end

-- Функция анимации питомца
local function animateFoundPet()
    print("\n🎯 === АНИМАЦИЯ НАЙДЕННОГО ПИТОМЦА ===")
    
    local petModel = findPetModel()
    if not petModel then
        print("❌ Сначала нужно найти питомца!")
        return
    end
    
    -- Клонируем модель питомца
    local petClone = petModel:Clone()
    petClone.Name = "AnimatedPetClone"
    
    -- Позиционируем рядом с игроком
    local playerPos = player.Character.HumanoidRootPart.Position
    local targetPos = playerPos + Vector3.new(3, 5, 0)
    
    if petClone:FindFirstChild("RootPart") then
        petClone.RootPart.Position = targetPos
        print("📍 Позиционировал через RootPart")
    elseif petClone.PrimaryPart then
        petClone:SetPrimaryPartCFrame(CFrame.new(targetPos))
        print("📍 Позиционировал через PrimaryPart")
    else
        petClone:MoveTo(targetPos)
        print("📍 Позиционировал через MoveTo")
    end
    
    petClone.Parent = Workspace
    print("🌍 Клон добавлен в Workspace")
    
    -- Подготавливаем все части к анимации
    local parts = {}
    local originalSizes = {}
    
    for _, part in pairs(petClone:GetChildren()) do
        if part:IsA("BasePart") then
            table.insert(parts, part)
            originalSizes[part] = part.Size
            
            -- Устанавливаем начальные параметры (как в записи яйца)
            part.Size = part.Size / 1.88  -- Маленький размер
            part.Transparency = 0.8       -- Полупрозрачный
            part.Anchored = true          -- Фиксируем
            part.CanCollide = false       -- Убираем коллизию
            
            print("  📦 Подготовил: " .. part.Name)
        end
    end
    
    print("📊 Подготовлено " .. #parts .. " частей к анимации")
    print("⏰ Начинаю анимацию роста...")
    
    -- Анимация роста (точно как в записи)
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
    button.Text = "⏳ ANIMATING..."
    button.BackgroundColor3 = Color3.new(1, 1, 0)
    
    spawn(function()
        animateFoundPet()
        
        wait(1)
        button.Text = "🎯 ANIMATE FOUND PET"
        button.BackgroundColor3 = Color3.new(0, 1, 0)
    end)
end)

print("🎯 Final Working Pet Animation готов!")
print("📋 Нажми кнопку и увидишь анимацию роста НАСТОЯЩЕГО питомца!")
print("🐾 Ищет модели с hex-именами и частями Head, Torso, RootPart")
