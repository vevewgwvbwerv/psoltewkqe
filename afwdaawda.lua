-- 🔍 СКАНЕР ВСЕГО РЯДОМ С ИГРОКОМ
-- Ищет ВСЕ объекты в радиусе 20 стадов от игрока

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

print("🔍 === СКАНЕР ВСЕГО РЯДОМ С ИГРОКОМ ===")
print("=" .. string.rep("=", 50))

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

-- ОЧЕНЬ МАЛЕНЬКИЙ РАДИУС - ТОЛЬКО САМОЕ БЛИЗКОЕ!
local SEARCH_RADIUS = 20  -- 20 стадов - очень близко!

print("🎯 Радиус поиска:", SEARCH_RADIUS, "стадов (ОЧЕНЬ БЛИЗКО!)")
print()

-- Функция сканирования
local function scanNearbyObjects()
    local nearbyObjects = {}
    local totalScanned = 0
    
    print("🔍 СКАНИРУЮ ВСЕ ОБЪЕКТЫ РЯДОМ С ИГРОКОМ...")
    print()
    
    -- Сканируем ВСЕ объекты в Workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
            totalScanned = totalScanned + 1
            
            -- Получаем позицию объекта
            local objPos = nil
            if obj:IsA("Model") then
                local success, modelCFrame = pcall(function() return obj:GetModelCFrame() end)
                if success then
                    objPos = modelCFrame.Position
                end
            elseif obj:IsA("BasePart") then
                objPos = obj.Position
            end
            
            if objPos then
                local distance = (objPos - playerPos).Magnitude
                
                -- ТОЛЬКО ОЧЕНЬ БЛИЗКИЕ ОБЪЕКТЫ!
                if distance <= SEARCH_RADIUS then
                    -- Определяем тип объекта
                    local objType = "Unknown"
                    local hasUUID = false
                    local hasCurlyBraces = false
                    local hasSquareBraces = false
                    local isPotentialPet = false
                    
                    -- Проверяем имя на UUID форматы
                    if obj.Name:find("%{") and obj.Name:find("%}") then
                        hasUUID = true
                        hasCurlyBraces = true
                        objType = "UUID (Curly {})"
                        isPotentialPet = true
                    elseif obj.Name:find("%[") and obj.Name:find("%]") then
                        hasUUID = true
                        hasSquareBraces = true
                        objType = "UUID (Square [])"
                        isPotentialPet = true
                    elseif obj.Name:find("Dog") or obj.Name:find("KG") then
                        objType = "Dog"
                        isPotentialPet = true
                    elseif obj.Name:find("Dragonfly") then
                        objType = "Dragonfly"
                        isPotentialPet = true
                    elseif obj.Name:find("Pet") or obj.Name:find("Age") then
                        objType = "Possible Pet"
                        isPotentialPet = true
                    end
                    
                    -- Считаем визуальные элементы
                    local meshCount = 0
                    if obj:IsA("Model") then
                        for _, child in pairs(obj:GetDescendants()) do
                            if child:IsA("MeshPart") or child:IsA("SpecialMesh") then
                                meshCount = meshCount + 1
                            end
                        end
                    elseif obj:IsA("MeshPart") then
                        meshCount = 1
                    end
                    
                    table.insert(nearbyObjects, {
                        object = obj,
                        distance = distance,
                        objType = objType,
                        hasUUID = hasUUID,
                        hasCurlyBraces = hasCurlyBraces,
                        hasSquareBraces = hasSquareBraces,
                        isPotentialPet = isPotentialPet,
                        meshCount = meshCount,
                        className = obj.ClassName
                    })
                end
            end
        end
    end
    
    -- Сортируем по расстоянию (ближайшие первые)
    table.sort(nearbyObjects, function(a, b) return a.distance < b.distance end)
    
    print("📊 === РЕЗУЛЬТАТЫ СКАНИРОВАНИЯ ===")
    print(string.format("📦 Всего объектов просканировано: %d", totalScanned))
    print(string.format("📍 Объектов рядом с игроком (в %d стадах): %d", SEARCH_RADIUS, #nearbyObjects))
    print()
    
    if #nearbyObjects == 0 then
        print("❌ РЯДОМ С ВАМИ НИЧЕГО НЕТ!")
        print("💡 Подойдите ближе к питомцу и запустите снова")
        return
    end
    
    -- Показываем все найденные объекты
    print("🎯 === ОБЪЕКТЫ РЯДОМ С ВАМИ ===")
    for i, item in ipairs(nearbyObjects) do
        local icon = "📦"
        if item.isPotentialPet then
            icon = "🐾"
        elseif item.hasUUID then
            icon = "🔑"
        end
        
        print(string.format("%s [%d] %s (%s)", icon, i, item.object.Name, item.className))
        print(string.format("    📏 Расстояние: %.1f стадов", item.distance))
        print(string.format("    🏷️ Тип: %s", item.objType))
        
        if item.hasUUID then
            if item.hasCurlyBraces then
                print("    🔑 UUID формат: Фигурные скобки {}")
            elseif item.hasSquareBraces then
                print("    🔑 UUID формат: Квадратные скобки []")
            end
        end
        
        print(string.format("    👀 Визуальные элементы: %d meshes", item.meshCount))
        
        if item.isPotentialPet then
            print("    🐾 *** ПОТЕНЦИАЛЬНЫЙ ПИТОМЕЦ! ***")
        end
        
        print()
    end
    
    -- Отдельно выделяем потенциальных питомцев
    local potentialPets = {}
    for _, item in ipairs(nearbyObjects) do
        if item.isPotentialPet then
            table.insert(potentialPets, item)
        end
    end
    
    if #potentialPets > 0 then
        print("🐾 === ПОТЕНЦИАЛЬНЫЕ ПИТОМЦЫ ===")
        for i, pet in ipairs(potentialPets) do
            print(string.format("🐾 [%d] %s", i, pet.object.Name))
            print(string.format("    📏 Расстояние: %.1f стадов", pet.distance))
            print(string.format("    🏷️ Тип: %s", pet.objType))
            print(string.format("    👀 Визуалы: %d meshes", pet.meshCount))
            print()
        end
    else
        print("❌ ПОТЕНЦИАЛЬНЫХ ПИТОМЦЕВ НЕ НАЙДЕНО!")
        print("💡 Подойдите вплотную к питомцу и запустите снова")
    end
end

-- Создание GUI
local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    local oldGui = playerGui:FindFirstChild("NearbyScannerGUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NearbyScannerGUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 250, 0, 80)
    frame.Position = UDim2.new(0, 50, 0, 250) -- Под PetScaler
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 165, 0) -- Оранжевая рамка
    frame.Parent = screenGui
    
    local button = Instance.new("TextButton")
    button.Name = "ScanButton"
    button.Size = UDim2.new(0, 230, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    button.BorderSizePixel = 0
    button.Text = "🔍 Сканировать рядом"
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ Сканирую..."
        button.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        
        spawn(function()
            scanNearbyObjects()
            
            wait(2)
            button.Text = "🔍 Сканировать рядом"
            button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        end)
    end)
    
    button.MouseEnter:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(255, 165, 0) then
            button.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if button.BackgroundColor3 == Color3.fromRGB(255, 140, 0) then
            button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        end
    end)
    
    print("🖥️ Nearby Scanner GUI создан!")
end

-- Запуск
createGUI()
print("=" .. string.rep("=", 50))
print("💡 NEARBY SCANNER:")
print("   1. Ищет ВСЕ объекты в радиусе 20 стадов")
print("   2. Показывает потенциальных питомцев")
print("   3. Анализирует UUID форматы и визуалы")
print("🎯 Подойдите ВПЛОТНУЮ к питомцу и нажмите кнопку!")
print("=" .. string.rep("=", 50))
