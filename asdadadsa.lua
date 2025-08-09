-- 🔬 PET SCRIPT ANALYZER - Анализ скриптов питомца
-- Фокус на анализе PetToolServer и PetToolLocal без спама в консоли

local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("🔬 === PET SCRIPT ANALYZER ===")

-- Глобальные переменные
local petTool = nil
local analysisResults = {}

-- Поиск питомца в руках
local function findPetInHands()
    local character = player.Character
    if not character then return nil end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "%[") and string.find(tool.Name, "KG%]") then
            return tool
        end
    end
    return nil
end

-- Анализ содержимого скрипта
local function analyzeScript(script)
    local info = {
        Name = script.Name,
        ClassName = script.ClassName,
        Parent = script.Parent.Name,
        Enabled = script.Enabled,
        Source = "Недоступен" -- Source недоступен в клиентских скриптах
    }
    
    -- Попытка получить дополнительную информацию
    if script:IsA("LocalScript") then
        info.Type = "LocalScript (Клиентский)"
        info.Description = "Управляет анимацией на стороне клиента"
    elseif script:IsA("Script") then
        info.Type = "ServerScript (Серверный)"  
        info.Description = "Управляет логикой на стороне сервера"
    end
    
    return info
end

-- Анализ всех скриптов питомца
local function analyzeAllScripts()
    print("\n🔍 === АНАЛИЗ СКРИПТОВ ПИТОМЦА ===")
    
    petTool = findPetInHands()
    if not petTool then
        print("❌ Питомец в руках не найден!")
        return
    end
    
    print("✅ Найден питомец: " .. petTool.Name)
    
    local scripts = {}
    
    -- Рекурсивный поиск всех скриптов
    local function findScripts(parent, depth)
        depth = depth or 0
        local indent = string.rep("  ", depth)
        
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("BaseScript") then
                table.insert(scripts, child)
                print(indent .. "📜 Найден скрипт: " .. child.Name .. " (" .. child.ClassName .. ")")
            end
            
            -- Рекурсивно ищем в дочерних объектах
            if #child:GetChildren() > 0 then
                findScripts(child, depth + 1)
            end
        end
    end
    
    findScripts(petTool)
    
    print("\n📊 === ДЕТАЛЬНЫЙ АНАЛИЗ СКРИПТОВ ===")
    
    if #scripts == 0 then
        print("❌ Скрипты не найдены!")
        return
    end
    
    for i, script in pairs(scripts) do
        print("\n🔍 СКРИПТ #" .. i .. ":")
        local info = analyzeScript(script)
        
        for key, value in pairs(info) do
            print("   " .. key .. ": " .. tostring(value))
        end
        
        -- Анализ связей скрипта
        print("   Дочерние объекты:")
        for _, child in pairs(script:GetChildren()) do
            print("     - " .. child.Name .. " (" .. child.ClassName .. ")")
        end
    end
    
    analysisResults.scripts = scripts
    print("\n✅ Анализ скриптов завершен!")
    print("📝 Найдено скриптов: " .. #scripts)
end

-- Анализ Motor6D и их связей
local function analyzeMotor6DConnections()
    print("\n🔧 === АНАЛИЗ MOTOR6D СВЯЗЕЙ ===")
    
    if not petTool then
        print("❌ Сначала проанализируйте скрипты!")
        return
    end
    
    local motor6ds = {}
    
    local function findMotor6Ds(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Motor6D") then
                table.insert(motor6ds, child)
            end
            findMotor6Ds(child)
        end
    end
    
    findMotor6Ds(petTool)
    
    print("🔧 Найдено Motor6D: " .. #motor6ds)
    
    -- Анализируем только первые 5 для краткости
    for i = 1, math.min(5, #motor6ds) do
        local motor = motor6ds[i]
        print("\n🔧 MOTOR6D #" .. i .. ": " .. motor.Name)
        print("   Part0: " .. (motor.Part0 and motor.Part0.Name or "nil"))
        print("   Part1: " .. (motor.Part1 and motor.Part1.Name or "nil"))
        print("   C0: " .. tostring(motor.C0))
        print("   C1: " .. tostring(motor.C1))
    end
    
    if #motor6ds > 5 then
        print("\n... и еще " .. (#motor6ds - 5) .. " Motor6D")
    end
    
    analysisResults.motor6ds = motor6ds
end

-- Создание GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetScriptAnalyzer"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 200)
    frame.Position = UDim2.new(0.5, -200, 0.5, -100)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🔬 PET SCRIPT ANALYZER"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- Кнопка анализа скриптов
    local analyzeBtn = Instance.new("TextButton")
    analyzeBtn.Size = UDim2.new(0.9, 0, 0, 40)
    analyzeBtn.Position = UDim2.new(0.05, 0, 0, 50)
    analyzeBtn.BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
    analyzeBtn.Text = "📜 АНАЛИЗ СКРИПТОВ"
    analyzeBtn.TextColor3 = Color3.new(1, 1, 1)
    analyzeBtn.TextScaled = true
    analyzeBtn.Font = Enum.Font.Gotham
    analyzeBtn.Parent = frame
    
    -- Кнопка анализа Motor6D
    local motorBtn = Instance.new("TextButton")
    motorBtn.Size = UDim2.new(0.9, 0, 0, 40)
    motorBtn.Position = UDim2.new(0.05, 0, 0, 100)
    motorBtn.BackgroundColor3 = Color3.new(0.8, 0.4, 0.2)
    motorBtn.Text = "🔧 АНАЛИЗ MOTOR6D"
    motorBtn.TextColor3 = Color3.new(1, 1, 1)
    motorBtn.TextScaled = true
    motorBtn.Font = Enum.Font.Gotham
    motorBtn.Parent = frame
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.9, 0, 0, 30)
    closeBtn.Position = UDim2.new(0.05, 0, 0, 150)
    closeBtn.BackgroundColor3 = Color3.new(0.6, 0.1, 0.1)
    closeBtn.Text = "❌ ЗАКРЫТЬ"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.Parent = frame
    
    -- Обработчики событий
    analyzeBtn.MouseButton1Click:Connect(analyzeAllScripts)
    motorBtn.MouseButton1Click:Connect(analyzeMotor6DConnections)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    print("🎮 GUI создан! Возьмите питомца в руки и нажмите кнопки для анализа.")
end

-- Запуск
createGUI()
