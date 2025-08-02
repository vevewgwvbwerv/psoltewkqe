--[[
    FINAL PET ANIMATION
    Финальная версия - копирует внешний вид питомца на растущий объект
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

print("🎯 Final Pet Animation загружен!")

-- Простой GUI с кнопкой
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FinalPetAnimation"
screenGui.Parent = CoreGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0, 10, 0, 370)
button.BackgroundColor3 = Color3.new(1, 0, 1)
button.Text = "🎯 FINAL PET ANIMATION"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.Parent = screenGui

-- Функция копирования внешнего вида питомца
local function copyPetAppearance(clone, originalTool)
    print("🎨 Копирую внешний вид питомца...")
    
    -- Ищем видимые части питомца в Tool
    for _, child in pairs(originalTool:GetChildren()) do
        if child:IsA("BasePart") and child.Name ~= "Handle" then
            -- Копируем цвет и материал
            clone.BrickColor = child.BrickColor
            clone.Material = child.Material
            clone.Color = child.Color
            
            print("  🎨 Скопировал цвет: " .. tostring(child.Color))
            print("  🎨 Скопировал материал: " .. child.Material.Name)
            
            -- Копируем текстуры и декали
            for _, texture in pairs(child:GetChildren()) do
                if texture:IsA("Decal") or texture:IsA("Texture") then
                    local textureClone = texture:Clone()
                    textureClone.Parent = clone
                    print("  🖼️ Скопировал текстуру: " .. texture.Name)
                end
            end
            
            -- Копируем меши
            for _, mesh in pairs(child:GetChildren()) do
                if mesh:IsA("SpecialMesh") then
                    local meshClone = mesh:Clone()
                    meshClone.Parent = clone
                    print("  🔷 Скопировал меш: " .. mesh.MeshType.Name)
                end
            end
            
            break -- Берем первую найденную видимую часть
        end
    end
    
    -- Если ничего не нашли, копируем с Handle
    local handle = originalTool:FindFirstChild("Handle")
    if handle then
        clone.BrickColor = handle.BrickColor
        clone.Material = handle.Material
        clone.Color = handle.Color
        
        print("  🎨 Скопировал с Handle: " .. tostring(handle.Color))
        
        -- Копируем все дочерние объекты Handle
        for _, child in pairs(handle:GetChildren()) do
            if not child:IsA("BaseScript") and not child:IsA("LocalScript") then
                local childClone = child:Clone()
                childClone.Parent = clone
                print("  📎 Скопировал: " .. child.Name .. " (" .. child.ClassName .. ")")
            end
        end
    end
end

-- Функция финального теста
local function finalPetAnimation()
    print("\n🎯 === ФИНАЛЬНАЯ АНИМАЦИЯ ПИТОМЦА ===")
    
    -- Получаем Tool
    local tool = nil
    for _, child in pairs(player.Character:GetChildren()) do
        if child:IsA("Tool") then
            tool = child
            break
        end
    end
    
    if not tool then
        print("❌ Tool не найден!")
        return
    end
    
    print("✅ Tool найден: " .. tool.Name)
    
    -- Находим Handle
    local handle = tool:FindFirstChild("Handle")
    if not handle then
        print("❌ Handle не найден!")
        return
    end
    
    -- Клонируем Handle
    local clone = handle:Clone()
    clone.Name = "FinalPetClone"
    
    -- Позиционируем клон
    local playerPos = player.Character.HumanoidRootPart.Position
    clone.Position = playerPos + Vector3.new(3, 5, 0)
    clone.Anchored = true
    clone.CanCollide = false
    clone.Parent = Workspace
    
    print("🌍 Клон добавлен в Workspace")
    
    -- Копируем внешний вид питомца
    copyPetAppearance(clone, tool)
    
    -- Устанавливаем размеры для анимации
    local targetSize = Vector3.new(4, 4, 4)  -- Большой размер
    local startSize = Vector3.new(1, 1, 1)   -- Начальный размер
    
    clone.Size = startSize
    clone.Transparency = 0.8
    
    print("📏 Начальный размер: " .. tostring(startSize))
    print("🎯 Целевой размер: " .. tostring(targetSize))
    
    -- Ждем 1 секунду
    wait(1)
    print("⏰ Начинаю анимацию роста питомца...")
    
    -- Анимация роста
    local steps = 20
    local sizeStep = (targetSize - startSize) / steps
    local transparencyStep = 0.8 / steps
    
    for i = 1, steps do
        local currentSize = startSize + (sizeStep * i)
        local currentTransparency = 0.8 - (transparencyStep * i)
        
        clone.Size = currentSize
        clone.Transparency = currentTransparency
        
        if i % 5 == 0 then
            print("🔄 Рост питомца: " .. i .. "/" .. steps .. " (" .. string.format("%.0f", (i/steps)*100) .. "%)")
        end
        
        wait(0.1)
    end
    
    print("✅ Анимация роста питомца завершена!")
    print("🎯 Теперь это должно выглядеть как твой питомец!")
    
    -- Ждем 5 секунд для осмотра
    wait(5)
    
    -- Исчезновение
    print("💥 Питомец исчезает...")
    for i = 1, 10 do
        clone.Transparency = i / 10
        wait(0.1)
    end
    
    clone:Destroy()
    print("🗑️ Анимация завершена!")
end

-- Обработчик кнопки
button.MouseButton1Click:Connect(function()
    button.Text = "⏳ ANIMATING..."
    button.BackgroundColor3 = Color3.new(1, 1, 0)
    
    spawn(function()
        finalPetAnimation()
        
        wait(1)
        button.Text = "🎯 FINAL PET ANIMATION"
        button.BackgroundColor3 = Color3.new(1, 0, 1)
    end)
end)

print("🎯 Final Pet Animation готов!")
print("📋 Этот тест скопирует внешний вид твоего питомца")
print("📋 И покажет его с анимацией роста!")
print("📋 Нажми кнопку и смотри на растущего питомца в воздухе!")
