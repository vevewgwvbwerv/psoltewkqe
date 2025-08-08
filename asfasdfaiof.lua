-- ShovelDeepDiagnostic.lua
-- ЖЕСТКАЯ ДИАГНОСТИКА Shovel - где находится, как связана со слотом 1

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== SHOVEL DEEP DIAGNOSTIC ===")

-- Функция глубокого поиска Shovel везде
local function findShovelEverywhere()
    print("\n🔍 === ПОИСК SHOVEL ВЕЗДЕ ===")
    
    local shovelLocations = {}
    local character = player.Character
    
    -- 1. Поиск в Character (руки)
    if character then
        print("📦 Поиск в Character:")
        for _, obj in pairs(character:GetChildren()) do
            if obj:IsA("Tool") and (string.find(obj.Name, "Shovel") or string.find(obj.Name, "Destroy")) then
                table.insert(shovelLocations, {
                    location = "Character (руки)",
                    tool = obj,
                    path = "Character." .. obj.Name
                })
                print("   ✅ Найден: " .. obj.Name .. " в руках")
            end
        end
        
        -- 2. Поиск в Backpack
        local backpack = character:FindFirstChild("Backpack")
        if backpack then
            print("📦 Поиск в Backpack:")
            for _, obj in pairs(backpack:GetChildren()) do
                if obj:IsA("Tool") and (string.find(obj.Name, "Shovel") or string.find(obj.Name, "Destroy")) then
                    table.insert(shovelLocations, {
                        location = "Backpack",
                        tool = obj,
                        path = "Character.Backpack." .. obj.Name
                    })
                    print("   ✅ Найден: " .. obj.Name .. " в Backpack")
                end
            end
        else
            print("   ❌ Backpack не найден!")
        end
    end
    
    -- 3. Поиск в PlayerGui
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        print("📦 Поиск в PlayerGui:")
        
        -- Рекурсивный поиск в GUI
        local function searchInGui(parent, path)
            for _, obj in pairs(parent:GetChildren()) do
                if obj.Name and (string.find(obj.Name, "Shovel") or string.find(obj.Name, "Destroy")) then
                    table.insert(shovelLocations, {
                        location = "PlayerGui",
                        tool = obj,
                        path = path .. "." .. obj.Name
                    })
                    print("   ✅ Найден GUI элемент: " .. obj.Name .. " в " .. path)
                end
                
                -- Рекурсивно ищем в детях
                if #obj:GetChildren() > 0 then
                    searchInGui(obj, path .. "." .. obj.Name)
                end
            end
        end
        
        searchInGui(playerGui, "PlayerGui")
    end
    
    -- 4. Поиск в StarterPack
    local starterPack = game:GetService("StarterPack")
    if starterPack then
        print("📦 Поиск в StarterPack:")
        for _, obj in pairs(starterPack:GetChildren()) do
            if obj:IsA("Tool") and (string.find(obj.Name, "Shovel") or string.find(obj.Name, "Destroy")) then
                table.insert(shovelLocations, {
                    location = "StarterPack",
                    tool = obj,
                    path = "StarterPack." .. obj.Name
                })
                print("   ✅ Найден: " .. obj.Name .. " в StarterPack")
            end
        end
    end
    
    return shovelLocations
end

-- Функция анализа связи со слотом 1
local function analyzeSlot1Connection()
    print("\n🔗 === АНАЛИЗ СВЯЗИ СО СЛОТОМ 1 ===")
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then
        print("❌ PlayerGui не найден!")
        return
    end
    
    local backpackGui = playerGui:FindFirstChild("BackpackGui")
    if not backpackGui then
        print("❌ BackpackGui не найден!")
        return
    end
    
    local backpack = backpackGui:FindFirstChild("Backpack")
    if not backpack then
        print("❌ Backpack Frame не найден!")
        return
    end
    
    local hotbar = backpack:FindFirstChild("Hotbar")
    if not hotbar then
        print("❌ Hotbar не найден!")
        return
    end
    
    local slot1 = hotbar:FindFirstChild("1")
    if not slot1 then
        print("❌ Слот 1 не найден!")
        return
    end
    
    print("✅ Найден слот 1: " .. slot1:GetFullName())
    
    -- Анализируем содержимое слота 1
    print("📋 Содержимое слота 1:")
    for _, child in pairs(slot1:GetDescendants()) do
        print("   📄 " .. child.ClassName .. ": " .. child.Name)
        
        if child:IsA("TextLabel") then
            print("      📝 Текст: '" .. child.Text .. "'")
        end
        
        if child:IsA("ImageLabel") then
            print("      🖼️ Image: " .. child.Image)
        end
        
        -- Ищем связи с Tool
        if child:IsA("ObjectValue") or child:IsA("StringValue") then
            print("      🔗 Значение: " .. tostring(child.Value))
        end
    end
    
    -- Ищем скрипты в слоте
    print("📜 Скрипты в слоте 1:")
    for _, child in pairs(slot1:GetDescendants()) do
        if child:IsA("LocalScript") or child:IsA("Script") then
            print("   📜 Скрипт: " .. child.Name .. " (" .. child.ClassName .. ")")
            print("      🔧 Enabled: " .. tostring(child.Enabled))
        end
    end
end

-- Функция анализа всех Tool в инвентаре
local function analyzeAllTools()
    print("\n🔧 === АНАЛИЗ ВСЕХ TOOL В ИНВЕНТАРЕ ===")
    
    local character = player.Character
    if not character then
        print("❌ Character не найден!")
        return
    end
    
    local allTools = {}
    
    -- Собираем все Tool
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(allTools, {tool = tool, location = "Character"})
        end
    end
    
    local backpack = character:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(allTools, {tool = tool, location = "Backpack"})
            end
        end
    end
    
    print("📊 Найдено Tool: " .. #allTools)
    
    for i, toolData in pairs(allTools) do
        local tool = toolData.tool
        print("\n🔧 Tool #" .. i .. ": " .. tool.Name)
        print("   📍 Местоположение: " .. toolData.location)
        print("   🆔 ClassName: " .. tool.ClassName)
        print("   👆 RequiresHandle: " .. tostring(tool.RequiresHandle))
        print("   🎯 CanBeDropped: " .. tostring(tool.CanBeDropped))
        print("   ⚡ Enabled: " .. tostring(tool.Enabled))
        
        -- Анализируем Handle
        local handle = tool:FindFirstChild("Handle")
        if handle then
            print("   🔗 Handle найден: " .. handle.ClassName)
            print("      📏 Size: " .. tostring(handle.Size))
            print("      🎨 Material: " .. handle.Material.Name)
            print("      🌈 Color: " .. tostring(handle.Color))
        else
            print("   ❌ Handle не найден!")
        end
        
        -- Считаем компоненты
        local parts = 0
        local meshes = 0
        local scripts = 0
        
        for _, child in pairs(tool:GetDescendants()) do
            if child:IsA("BasePart") then
                parts = parts + 1
            elseif child:IsA("SpecialMesh") then
                meshes = meshes + 1
            elseif child:IsA("LocalScript") or child:IsA("Script") then
                scripts = scripts + 1
            end
        end
        
        print("   📊 Компоненты: " .. parts .. " частей, " .. meshes .. " мешей, " .. scripts .. " скриптов")
    end
end

-- Функция создания отчета
local function createDiagnosticReport()
    print("\n📋 === СОЗДАНИЕ ДИАГНОСТИЧЕСКОГО ОТЧЕТА ===")
    
    local report = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        shovelLocations = findShovelEverywhere(),
        playerInfo = {
            name = player.Name,
            userId = player.UserId
        }
    }
    
    print("📄 ОТЧЕТ ДИАГНОСТИКИ:")
    print("🕒 Время: " .. report.timestamp)
    print("👤 Игрок: " .. report.playerInfo.name .. " (ID: " .. report.playerInfo.userId .. ")")
    print("🔍 Найдено Shovel локаций: " .. #report.shovelLocations)
    
    for i, location in pairs(report.shovelLocations) do
        print("   " .. i .. ". " .. location.location .. " - " .. location.tool.Name)
        print("      📍 Путь: " .. location.path)
        print("      🆔 Класс: " .. location.tool.ClassName)
    end
    
    return report
end

-- Создаем GUI для диагностики
local function createDiagnosticGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ShovelDeepDiagnosticGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 400)
    frame.Position = UDim2.new(0.5, -250, 0.5, -200)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.8, 0, 0)
    title.BorderSizePixel = 0
    title.Text = "🔍 ЖЕСТКАЯ ДИАГНОСТИКА SHOVEL"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "Готов к диагностике. Нажмите кнопки для анализа Shovel."
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.SourceSans
    status.TextWrapped = true
    status.Parent = frame
    
    -- Кнопка поиска Shovel
    local findBtn = Instance.new("TextButton")
    findBtn.Size = UDim2.new(1, -20, 0, 40)
    findBtn.Position = UDim2.new(0, 10, 0, 120)
    findBtn.BackgroundColor3 = Color3.new(0.8, 0, 0)
    findBtn.BorderSizePixel = 0
    findBtn.Text = "🔍 Найти Shovel везде"
    findBtn.TextColor3 = Color3.new(1, 1, 1)
    findBtn.TextScaled = true
    findBtn.Font = Enum.Font.SourceSansBold
    findBtn.Parent = frame
    
    -- Кнопка анализа слота 1
    local slot1Btn = Instance.new("TextButton")
    slot1Btn.Size = UDim2.new(1, -20, 0, 40)
    slot1Btn.Position = UDim2.new(0, 10, 0, 170)
    slot1Btn.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
    slot1Btn.BorderSizePixel = 0
    slot1Btn.Text = "🔗 Анализ связи со слотом 1"
    slot1Btn.TextColor3 = Color3.new(1, 1, 1)
    slot1Btn.TextScaled = true
    slot1Btn.Font = Enum.Font.SourceSansBold
    slot1Btn.Parent = frame
    
    -- Кнопка анализа всех Tool
    local allToolsBtn = Instance.new("TextButton")
    allToolsBtn.Size = UDim2.new(1, -20, 0, 40)
    allToolsBtn.Position = UDim2.new(0, 10, 0, 220)
    allToolsBtn.BackgroundColor3 = Color3.new(0, 0.6, 0.8)
    allToolsBtn.BorderSizePixel = 0
    allToolsBtn.Text = "🔧 Анализ всех Tool"
    allToolsBtn.TextColor3 = Color3.new(1, 1, 1)
    allToolsBtn.TextScaled = true
    allToolsBtn.Font = Enum.Font.SourceSansBold
    allToolsBtn.Parent = frame
    
    -- Кнопка полного отчета
    local reportBtn = Instance.new("TextButton")
    reportBtn.Size = UDim2.new(1, -20, 0, 40)
    reportBtn.Position = UDim2.new(0, 10, 0, 270)
    reportBtn.BackgroundColor3 = Color3.new(0.6, 0, 0.8)
    reportBtn.BorderSizePixel = 0
    reportBtn.Text = "📋 Полный диагностический отчет"
    reportBtn.TextColor3 = Color3.new(1, 1, 1)
    reportBtn.TextScaled = true
    reportBtn.Font = Enum.Font.SourceSansBold
    reportBtn.Parent = frame
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -20, 0, 40)
    closeBtn.Position = UDim2.new(0, 10, 0, 320)
    closeBtn.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "❌ Закрыть"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = frame
    
    -- События кнопок
    findBtn.MouseButton1Click:Connect(function()
        status.Text = "🔍 Ищу Shovel везде..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local locations = findShovelEverywhere()
        
        if #locations > 0 then
            status.Text = "✅ Найдено " .. #locations .. " Shovel! Проверьте консоль."
            status.TextColor3 = Color3.new(0, 1, 0)
        else
            status.Text = "❌ Shovel не найден нигде!"
            status.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    slot1Btn.MouseButton1Click:Connect(function()
        status.Text = "🔗 Анализирую связь со слотом 1..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        analyzeSlot1Connection()
        
        status.Text = "✅ Анализ слота 1 завершен! Проверьте консоль."
        status.TextColor3 = Color3.new(0, 1, 0)
    end)
    
    allToolsBtn.MouseButton1Click:Connect(function()
        status.Text = "🔧 Анализирую все Tool..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        analyzeAllTools()
        
        status.Text = "✅ Анализ всех Tool завершен! Проверьте консоль."
        status.TextColor3 = Color3.new(0, 1, 0)
    end)
    
    reportBtn.MouseButton1Click:Connect(function()
        status.Text = "📋 Создаю полный отчет..."
        status.TextColor3 = Color3.new(1, 1, 0)
        
        local report = createDiagnosticReport()
        analyzeSlot1Connection()
        analyzeAllTools()
        
        status.Text = "✅ Полный отчет готов! Проверьте консоль."
        status.TextColor3 = Color3.new(0, 1, 0)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- Запускаем диагностику
createDiagnosticGUI()
print("✅ ShovelDeepDiagnostic готов!")
print("🔍 Используйте кнопки для жесткой диагностики Shovel")
print("📋 Все результаты будут в консоли с подробной информацией")
