-- ShovelAnalyzer.lua
-- Анализ структуры Shovel для понимания как его заменить

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== SHOVEL ANALYZER ===")

-- Функция поиска Shovel в руке
local function findShovelInHand()
    local character = player.Character
    if not character then return nil end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and (string.find(tool.Name, "Shovel") or string.find(tool.Name, "Destroy")) then
            return tool
        end
    end
    return nil
end

-- Функция поиска питомца в руке
local function findPetInHand()
    local character = player.Character
    if not character then return nil end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "%[") and string.find(tool.Name, "KG%]") then
            return tool
        end
    end
    return nil
end

-- Функция анализа Tool
local function analyzeTool(tool, toolType)
    if not tool then return end
    
    print("\n🔍 === АНАЛИЗ " .. toolType .. ": " .. tool.Name .. " ===")
    
    local structure = {
        name = tool.Name,
        className = tool.ClassName,
        parts = {},
        meshes = {},
        scripts = {},
        motor6ds = {},
        welds = {},
        totalChildren = 0
    }
    
    -- Анализируем все компоненты
    for _, obj in pairs(tool:GetDescendants()) do
        structure.totalChildren = structure.totalChildren + 1
        
        if obj:IsA("BasePart") then
            table.insert(structure.parts, {
                name = obj.Name,
                className = obj.ClassName,
                size = obj.Size,
                material = obj.Material.Name,
                color = obj.Color,
                transparency = obj.Transparency,
                canCollide = obj.CanCollide,
                anchored = obj.Anchored
            })
            print("🧱 Part: " .. obj.Name .. " (" .. obj.ClassName .. ") | Size: " .. tostring(obj.Size))
            
        elseif obj:IsA("SpecialMesh") then
            table.insert(structure.meshes, {
                name = obj.Name,
                meshType = obj.MeshType.Name,
                meshId = obj.MeshId,
                textureId = obj.TextureId,
                scale = obj.Scale
            })
            print("🎨 Mesh: " .. obj.Name .. " | Type: " .. obj.MeshType.Name .. " | MeshId: " .. obj.MeshId)
            
        elseif obj:IsA("Motor6D") then
            table.insert(structure.motor6ds, {
                name = obj.Name,
                part0 = obj.Part0 and obj.Part0.Name or "NIL",
                part1 = obj.Part1 and obj.Part1.Name or "NIL"
            })
            print("⚙️ Motor6D: " .. obj.Name .. " | " .. (obj.Part0 and obj.Part0.Name or "NIL") .. " → " .. (obj.Part1 and obj.Part1.Name or "NIL"))
            
        elseif obj:IsA("Weld") then
            table.insert(structure.welds, {
                name = obj.Name,
                part0 = obj.Part0 and obj.Part0.Name or "NIL",
                part1 = obj.Part1 and obj.Part1.Name or "NIL"
            })
            print("🔗 Weld: " .. obj.Name)
            
        elseif obj:IsA("LocalScript") or obj:IsA("Script") then
            table.insert(structure.scripts, {
                name = obj.Name,
                className = obj.ClassName,
                enabled = obj.Enabled
            })
            print("📜 Script: " .. obj.Name .. " (" .. obj.ClassName .. ")")
        end
    end
    
    print("📊 Итого в " .. toolType .. ":")
    print("   🧱 Частей: " .. #structure.parts)
    print("   🎨 Мешей: " .. #structure.meshes)
    print("   ⚙️ Motor6D: " .. #structure.motor6ds)
    print("   🔗 Weld: " .. #structure.welds)
    print("   📜 Скриптов: " .. #structure.scripts)
    print("   📦 Всего объектов: " .. structure.totalChildren)
    
    return structure
end

-- Функция замены структуры Shovel на структуру питомца
local function replaceShovelStructure(shovelTool, petTool)
    if not shovelTool or not petTool then
        print("❌ Shovel или питомец не найден!")
        return false
    end
    
    print("\n🔄 === ЗАМЕНА СТРУКТУРЫ SHOVEL НА ПИТОМЦА ===")
    print("🔄 Заменяю: " .. shovelTool.Name .. " → " .. petTool.Name)
    
    -- Сохраняем имя и родителя Shovel
    local shovelName = shovelTool.Name
    local shovelParent = shovelTool.Parent
    
    -- Удаляем все содержимое Shovel
    print("🗑️ Очищаю содержимое Shovel...")
    for _, child in pairs(shovelTool:GetChildren()) do
        child:Destroy()
    end
    
    -- Копируем все содержимое питомца в Shovel
    print("📋 Копирую содержимое питомца в Shovel...")
    for _, child in pairs(petTool:GetChildren()) do
        local childCopy = child:Clone()
        childCopy.Parent = shovelTool
        print("   ✅ Скопирован: " .. child.Name .. " (" .. child.ClassName .. ")")
    end
    
    -- Меняем имя Shovel на Dragonfly
    shovelTool.Name = "Dragonfly [6.36 KG] [Age 35]"
    
    print("✅ Структура Shovel заменена на структуру питомца!")
    print("✅ Shovel теперь называется: " .. shovelTool.Name)
    
    return true
end

-- Создаем GUI для анализа и замены
local function createAnalyzerGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ShovelAnalyzerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 400)
    frame.Position = UDim2.new(0.5, -250, 0.5, -200)
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    title.BorderSizePixel = 0
    title.Text = "🔍 Анализатор и заменитель Shovel"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "Готов к анализу. Возьмите Shovel или питомца в руки."
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    -- Кнопка анализа Shovel
    local analyzeShovelBtn = Instance.new("TextButton")
    analyzeShovelBtn.Size = UDim2.new(1, -20, 0, 40)
    analyzeShovelBtn.Position = UDim2.new(0, 10, 0, 120)
    analyzeShovelBtn.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
    analyzeShovelBtn.BorderSizePixel = 0
    analyzeShovelBtn.Text = "🔍 Анализировать Shovel в руке"
    analyzeShovelBtn.TextColor3 = Color3.new(1, 1, 1)
    analyzeShovelBtn.TextScaled = true
    analyzeShovelBtn.Font = Enum.Font.SourceSansBold
    analyzeShovelBtn.Parent = frame
    
    -- Кнопка анализа питомца
    local analyzePetBtn = Instance.new("TextButton")
    analyzePetBtn.Size = UDim2.new(1, -20, 0, 40)
    analyzePetBtn.Position = UDim2.new(0, 10, 0, 170)
    analyzePetBtn.BackgroundColor3 = Color3.new(0, 0.6, 0.8)
    analyzePetBtn.BorderSizePixel = 0
    analyzePetBtn.Text = "🔍 Анализировать питомца в руке"
    analyzePetBtn.TextColor3 = Color3.new(1, 1, 1)
    analyzePetBtn.TextScaled = true
    analyzePetBtn.Font = Enum.Font.SourceSansBold
    analyzePetBtn.Parent = frame
    
    -- Кнопка замены структуры
    local replaceBtn = Instance.new("TextButton")
    replaceBtn.Size = UDim2.new(1, -20, 0, 40)
    replaceBtn.Position = UDim2.new(0, 10, 0, 220)
    replaceBtn.BackgroundColor3 = Color3.new(0.8, 0, 0.8)
    replaceBtn.BorderSizePixel = 0
    replaceBtn.Text = "🔄 ЗАМЕНИТЬ структуру Shovel на питомца"
    replaceBtn.TextColor3 = Color3.new(1, 1, 1)
    replaceBtn.TextScaled = true
    replaceBtn.Font = Enum.Font.SourceSansBold
    replaceBtn.Parent = frame
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -20, 0, 40)
    closeBtn.Position = UDim2.new(0, 10, 0, 320)
    closeBtn.BackgroundColor3 = Color3.new(0.6, 0, 0)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "❌ Закрыть"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = frame
    
    -- События кнопок
    analyzeShovelBtn.MouseButton1Click:Connect(function()
        local shovel = findShovelInHand()
        if shovel then
            status.Text = "🔍 Анализирую Shovel: " .. shovel.Name
            status.TextColor3 = Color3.new(0, 1, 1)
            analyzeTool(shovel, "SHOVEL")
            status.Text = "✅ Анализ Shovel завершен! Проверьте консоль."
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Shovel в руке не найден!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    analyzePetBtn.MouseButton1Click:Connect(function()
        local pet = findPetInHand()
        if pet then
            status.Text = "🔍 Анализирую питомца: " .. pet.Name
            status.TextColor3 = Color3.new(0, 1, 1)
            analyzeTool(pet, "ПИТОМЕЦ")
            status.Text = "✅ Анализ питомца завершен! Проверьте консоль."
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Питомец в руке не найден!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    replaceBtn.MouseButton1Click:Connect(function()
        local shovel = findShovelInHand()
        local pet = findPetInHand()
        
        if not shovel and not pet then
            status.Text = "❌ Нужен Shovel И питомец! Сначала возьмите Shovel, затем питомца."
            status.TextColor3 = Color3.new(1, 0, 0)
            return
        end
        
        -- Если в руке питомец, ищем Shovel в Backpack
        if not shovel then
            local character = player.Character
            local backpack = character and character:FindFirstChild("Backpack")
            if backpack then
                for _, tool in pairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and (string.find(tool.Name, "Shovel") or string.find(tool.Name, "Destroy")) then
                        shovel = tool
                        break
                    end
                end
            end
        end
        
        if shovel and pet then
            status.Text = "🔄 Заменяю структуру Shovel на питомца..."
            status.TextColor3 = Color3.new(1, 1, 0)
            
            local success = replaceShovelStructure(shovel, pet)
            
            if success then
                status.Text = "✅ Структура Shovel заменена на питомца!"
                status.TextColor3 = Color3.new(0, 1, 0)
            else
                status.Text = "❌ Ошибка при замене структуры!"
                status.TextColor3 = Color3.new(1, 0, 0)
            end
        else
            status.Text = "❌ Не найден Shovel или питомец!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- Запускаем анализатор
createAnalyzerGUI()
print("✅ ShovelAnalyzer готов!")
print("🎮 Инструкция:")
print("   1. Возьмите Shovel в руки → Анализируйте")
print("   2. Возьмите питомца в руки → Анализируйте") 
print("   3. Нажмите 'ЗАМЕНИТЬ структуру' для замены")
print("   4. Проверьте результат!")
