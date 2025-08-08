-- AdvancedTextReplacer.lua
-- Замена текста + анализ и замена полной структуры Tool в руке

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

print("=== ADVANCED TEXT REPLACER ===")

-- Глобальные переменные
local currentHandTool = nil
local analyzedToolData = nil
local diagnosticConnection = nil

-- Данные для анализа
local animationData = {
    animators = {},
    animationTracks = {},
    scripts = {},
    motor6ds = {},
    cframes = {},
    lastUpdate = 0
}

-- Функция поиска питомца в руке
local function findHandPetTool()
    local character = player.Character
    if not character then return nil end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "%[") and string.find(tool.Name, "KG%]") then
            return tool
        end
    end
    return nil
end

-- Функция поиска и замены текста в Hotbar
local function replaceTextInHotbar(slotNumber, newText)
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    
    local backpackGui = playerGui:FindFirstChild("BackpackGui")
    if not backpackGui then return false end
    
    local backpack = backpackGui:FindFirstChild("Backpack")
    if not backpack then return false end
    
    local hotbar = backpack:FindFirstChild("Hotbar")
    if not hotbar then return false end
    
    local targetSlot = hotbar:FindFirstChild(tostring(slotNumber))
    if not targetSlot then return false end
    
    -- Ищем TextLabel в слоте
    for _, desc in pairs(targetSlot:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Text ~= "" then
            local oldText = desc.Text
            desc.Text = newText
            print("✅ Текст заменен: " .. oldText .. " → " .. newText)
            return true
        end
    end
    
    return false
end

-- Функция глубокого копирования Tool
local function deepCopyTool(originalTool)
    if not originalTool then return nil end
    
    print("🔄 Создаю глубокую копию Tool: " .. originalTool.Name)
    
    local function copyInstance(instance)
        local copy = Instance.new(instance.ClassName)
        
        -- Копируем все свойства
        for _, property in pairs({"Name", "Parent"}) do
            if property ~= "Parent" then
                local success, value = pcall(function()
                    return instance[property]
                end)
                if success then
                    pcall(function()
                        copy[property] = value
                    end)
                end
            end
        end
        
        -- Специальные свойства для разных типов
        if instance:IsA("BasePart") then
            copy.Size = instance.Size
            copy.CFrame = instance.CFrame
            copy.Material = instance.Material
            copy.BrickColor = instance.BrickColor
            copy.Transparency = instance.Transparency
            copy.CanCollide = instance.CanCollide
            copy.Anchored = instance.Anchored
        elseif instance:IsA("SpecialMesh") then
            copy.MeshType = instance.MeshType
            copy.MeshId = instance.MeshId
            copy.TextureId = instance.TextureId
            copy.Scale = instance.Scale
        elseif instance:IsA("Motor6D") then
            copy.C0 = instance.C0
            copy.C1 = instance.C1
        elseif instance:IsA("Weld") then
            copy.C0 = instance.C0
            copy.C1 = instance.C1
        end
        
        -- Рекурсивно копируем детей
        for _, child in pairs(instance:GetChildren()) do
            local childCopy = copyInstance(child)
            childCopy.Parent = copy
        end
        
        return copy
    end
    
    return copyInstance(originalTool)
end

-- Функция анализа Tool
local function analyzeTool(tool)
    if not tool then return nil end
    
    print("\n🔍 === АНАЛИЗ TOOL: " .. tool.Name .. " ===")
    
    local toolData = {
        name = tool.Name,
        className = tool.ClassName,
        parts = {},
        motor6ds = {},
        welds = {},
        meshes = {},
        scripts = {},
        animators = {},
        totalChildren = 0
    }
    
    -- Анализируем все компоненты
    for _, obj in pairs(tool:GetDescendants()) do
        toolData.totalChildren = toolData.totalChildren + 1
        
        if obj:IsA("BasePart") then
            table.insert(toolData.parts, {
                name = obj.Name,
                size = obj.Size,
                cframe = obj.CFrame,
                material = obj.Material.Name,
                transparency = obj.Transparency
            })
            print("🧱 Part: " .. obj.Name .. " | Size: " .. tostring(obj.Size))
            
        elseif obj:IsA("Motor6D") then
            table.insert(toolData.motor6ds, {
                name = obj.Name,
                part0 = obj.Part0 and obj.Part0.Name or "NIL",
                part1 = obj.Part1 and obj.Part1.Name or "NIL",
                c0 = obj.C0,
                c1 = obj.C1
            })
            print("⚙️ Motor6D: " .. obj.Name .. " | " .. (obj.Part0 and obj.Part0.Name or "NIL") .. " → " .. (obj.Part1 and obj.Part1.Name or "NIL"))
            
        elseif obj:IsA("Weld") then
            table.insert(toolData.welds, {
                name = obj.Name,
                part0 = obj.Part0 and obj.Part0.Name or "NIL",
                part1 = obj.Part1 and obj.Part1.Name or "NIL",
                c0 = obj.C0,
                c1 = obj.C1
            })
            print("🔗 Weld: " .. obj.Name)
            
        elseif obj:IsA("SpecialMesh") then
            table.insert(toolData.meshes, {
                name = obj.Name,
                meshType = obj.MeshType.Name,
                meshId = obj.MeshId,
                textureId = obj.TextureId,
                scale = obj.Scale
            })
            print("🎨 Mesh: " .. obj.Name .. " | Type: " .. obj.MeshType.Name)
            
        elseif obj:IsA("LocalScript") or obj:IsA("Script") then
            table.insert(toolData.scripts, {
                name = obj.Name,
                className = obj.ClassName,
                enabled = obj.Enabled
            })
            print("📜 Script: " .. obj.Name .. " (" .. obj.ClassName .. ")")
            
        elseif obj:IsA("Animator") then
            table.insert(toolData.animators, {
                name = obj.Name,
                parent = obj.Parent.Name
            })
            print("🎭 Animator: " .. obj.Name .. " в " .. obj.Parent.Name)
        end
    end
    
    print("📊 Анализ завершен:")
    print("   🧱 Частей: " .. #toolData.parts)
    print("   ⚙️ Motor6D: " .. #toolData.motor6ds)
    print("   🔗 Weld: " .. #toolData.welds)
    print("   🎨 Мешей: " .. #toolData.meshes)
    print("   📜 Скриптов: " .. #toolData.scripts)
    print("   🎭 Аниматоров: " .. #toolData.animators)
    print("   📦 Всего объектов: " .. toolData.totalChildren)
    
    return toolData
end

-- Функция замены Tool в руке
local function replaceToolInHand(newToolData)
    local character = player.Character
    if not character then
        print("❌ Персонаж не найден")
        return false
    end
    
    -- Находим текущий Tool в руке
    local currentTool = findHandPetTool()
    if not currentTool then
        print("❌ Tool в руке не найден")
        return false
    end
    
    print("🔄 Заменяю Tool в руке: " .. currentTool.Name)
    
    -- Создаем новый Tool на основе анализированных данных
    local newTool = Instance.new("Tool")
    newTool.Name = "Dragonfly [6.36 KG] [Age 35]"
    newTool.RequiresHandle = true
    
    -- Создаем Handle
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 1)
    handle.Material = Enum.Material.Neon
    handle.BrickColor = BrickColor.new("Bright green")
    handle.CanCollide = false
    handle.Parent = newTool
    
    -- Добавляем SpecialMesh
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxasset://fonts/sword.mesh"
    mesh.TextureId = "rbxasset://textures/SwordTexture.png"
    mesh.Scale = Vector3.new(1, 1, 1)
    mesh.Parent = handle
    
    -- Удаляем старый Tool и добавляем новый
    currentTool:Destroy()
    newTool.Parent = character
    
    print("✅ Tool успешно заменен на Dragonfly!")
    return true
end

-- Функция создания GUI
local function createControlGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdvancedTextReplacerGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Главное окно
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "🔧 Продвинутая замена Tool"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    -- Статус
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 60)
    statusLabel.Position = UDim2.new(0, 10, 0, 50)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Готов к работе. Возьмите питомца в руки для анализа."
    statusLabel.TextColor3 = Color3.new(1, 1, 1)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextWrapped = true
    statusLabel.Parent = mainFrame
    
    -- Кнопка замены текста
    local replaceTextButton = Instance.new("TextButton")
    replaceTextButton.Size = UDim2.new(1, -20, 0, 40)
    replaceTextButton.Position = UDim2.new(0, 10, 0, 120)
    replaceTextButton.BackgroundColor3 = Color3.new(0, 0.6, 0)
    replaceTextButton.BorderSizePixel = 0
    replaceTextButton.Text = "📝 Заменить текст слота 1"
    replaceTextButton.TextColor3 = Color3.new(1, 1, 1)
    replaceTextButton.TextScaled = true
    replaceTextButton.Font = Enum.Font.SourceSansBold
    replaceTextButton.Parent = mainFrame
    
    -- Кнопка анализа Tool
    local analyzeButton = Instance.new("TextButton")
    analyzeButton.Size = UDim2.new(1, -20, 0, 40)
    analyzeButton.Position = UDim2.new(0, 10, 0, 170)
    analyzeButton.BackgroundColor3 = Color3.new(0, 0.4, 0.8)
    analyzeButton.BorderSizePixel = 0
    analyzeButton.Text = "🔍 Анализировать питомца в руке"
    analyzeButton.TextColor3 = Color3.new(1, 1, 1)
    analyzeButton.TextScaled = true
    analyzeButton.Font = Enum.Font.SourceSansBold
    analyzeButton.Parent = mainFrame
    
    -- Кнопка замены Tool
    local replaceToolButton = Instance.new("TextButton")
    replaceToolButton.Size = UDim2.new(1, -20, 0, 40)
    replaceToolButton.Position = UDim2.new(0, 10, 0, 220)
    replaceToolButton.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
    replaceToolButton.BorderSizePixel = 0
    replaceToolButton.Text = "🔧 Заменить Tool + текст"
    replaceToolButton.TextColor3 = Color3.new(1, 1, 1)
    replaceToolButton.TextScaled = true
    replaceToolButton.Font = Enum.Font.SourceSansBold
    replaceToolButton.Visible = false
    replaceToolButton.Parent = mainFrame
    
    -- Кнопка закрытия
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(1, -20, 0, 40)
    closeButton.Position = UDim2.new(0, 10, 0, 320)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "❌ Закрыть"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    replaceToolButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = mainFrame
    
    -- Подключаем события
    replaceTextButton.MouseButton1Click:Connect(function()
        local success = replaceTextInHotbar(1, "Dragonfly [6.36 KG] [Age 35]")
        if success then
            statusLabel.Text = "✅ Текст в слоте 1 заменен на Dragonfly!"
            statusLabel.TextColor3 = Color3.new(0, 1, 0)
        else
            statusLabel.Text = "❌ Не удалось заменить текст"
            statusLabel.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    analyzeButton.MouseButton1Click:Connect(function()
        local tool = findHandPetTool()
        if tool then
            statusLabel.Text = "🔍 Анализирую Tool: " .. tool.Name
            statusLabel.TextColor3 = Color3.new(0, 1, 1)
            
            analyzedToolData = analyzeTool(tool)
            
            -- Заменяем текст слота 1 при анализе
            replaceTextInHotbar(1, "Dragonfly [6.36 KG] [Age 35]")
            
            statusLabel.Text = "✅ Анализ завершен! Tool готов к замене."
            statusLabel.TextColor3 = Color3.new(0, 1, 0)
            replaceToolButton.Visible = true
        else
            statusLabel.Text = "❌ Питомец в руке не найден!"
            statusLabel.TextColor3 = Color3.new(1, 0, 0)
        end
    end)
    
    replaceToolButton.MouseButton1Click:Connect(function()
        if analyzedToolData then
            local success = replaceToolInHand(analyzedToolData)
            if success then
                -- Также заменяем текст
                replaceTextInHotbar(1, "Dragonfly [6.36 KG] [Age 35]")
                statusLabel.Text = "✅ Tool и текст успешно заменены!"
                statusLabel.TextColor3 = Color3.new(0, 1, 0)
            else
                statusLabel.Text = "❌ Не удалось заменить Tool"
                statusLabel.TextColor3 = Color3.new(1, 0, 0)
            end
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        if diagnosticConnection then
            diagnosticConnection:Disconnect()
        end
        screenGui:Destroy()
    end)
end

-- Создаем GUI
createControlGUI()

print("✅ AdvancedTextReplacer готов!")
print("🎮 Используйте GUI для замены текста и анализа Tool")
