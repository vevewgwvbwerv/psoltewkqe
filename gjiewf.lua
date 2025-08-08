-- InventoryStructureAnalyzer.lua
-- Полный анализ структуры GUI для поиска основного инвентаря

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- GUI элементы
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryStructureAnalyzer"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 500)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "🔍 Анализ структуры инвентаря"
titleLabel.TextColor3 = Color3.white
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

-- Область логов
local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(1, -20, 1, -100)
logFrame.Position = UDim2.new(0, 10, 0, 50)
logFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
logFrame.BorderSizePixel = 0
logFrame.ScrollBarThickness = 8
logFrame.Parent = mainFrame

-- Кнопка анализа
local analyzeButton = Instance.new("TextButton")
analyzeButton.Size = UDim2.new(0, 200, 0, 30)
analyzeButton.Position = UDim2.new(0.5, -100, 1, -40)
analyzeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
analyzeButton.BorderSizePixel = 0
analyzeButton.Text = "🔍 Анализировать структуру"
analyzeButton.TextColor3 = Color3.white
analyzeButton.TextScaled = true
analyzeButton.Font = Enum.Font.SourceSansBold
analyzeButton.Parent = mainFrame

-- Переменные для логирования
local logYPosition = 0
local logs = {}

-- Функция добавления лога
local function addLog(text, color)
    color = color or Color3.white
    
    local logLabel = Instance.new("TextLabel")
    logLabel.Size = UDim2.new(1, -10, 0, 20)
    logLabel.Position = UDim2.new(0, 5, 0, logYPosition)
    logLabel.BackgroundTransparency = 1
    logLabel.Text = text
    logLabel.TextColor3 = color
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.TextScaled = true
    logLabel.Font = Enum.Font.SourceSans
    logLabel.Parent = logFrame
    
    logYPosition = logYPosition + 22
    logFrame.CanvasSize = UDim2.new(0, 0, 0, logYPosition)
    logFrame.CanvasPosition = Vector2.new(0, logYPosition)
    
    table.insert(logs, {label = logLabel, text = text})
    print(text)
end

-- Функция очистки логов
local function clearLogs()
    for _, log in pairs(logs) do
        if log.label then
            log.label:Destroy()
        end
    end
    logs = {}
    logYPosition = 0
    logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

-- Функция анализа GUI элемента
local function analyzeGuiElement(element, depth, parentPath)
    depth = depth or 0
    parentPath = parentPath or ""
    
    local indent = string.rep("  ", depth)
    local path = parentPath .. "/" .. element.Name
    local info = indent .. "📁 " .. element.Name .. " (" .. element.ClassName .. ")"
    
    -- Дополнительная информация для разных типов элементов
    if element:IsA("Frame") or element:IsA("ScrollingFrame") then
        local childCount = 0
        local buttonCount = 0
        local textButtonCount = 0
        
        for _, child in pairs(element:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible then
                childCount = childCount + 1
                if child:IsA("TextButton") then
                    textButtonCount = textButtonCount + 1
                elseif child:IsA("GuiButton") then
                    buttonCount = buttonCount + 1
                end
            end
        end
        
        if childCount > 0 then
            info = info .. " [" .. childCount .. " элементов"
            if textButtonCount > 0 then
                info = info .. ", " .. textButtonCount .. " кнопок"
            end
            info = info .. "]"
        end
        
        -- Проверяем, может ли это быть основным инвентарем
        if childCount >= 8 and childCount <= 15 and textButtonCount >= 5 then
            info = info .. " ⭐ ВОЗМОЖНЫЙ ОСНОВНОЙ ИНВЕНТАРЬ!"
            addLog(info, Color3.fromRGB(0, 255, 0))
        else
            addLog(info, Color3.fromRGB(200, 200, 200))
        end
        
    elseif element:IsA("TextButton") then
        local hasText = false
        local buttonText = ""
        
        -- Ищем текст в кнопке
        for _, desc in pairs(element:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Text ~= "" then
                buttonText = desc.Text
                hasText = true
                break
            end
        end
        
        if hasText then
            info = info .. " [" .. buttonText .. "]"
            
            -- Проверяем, это питомец или предмет
            if buttonText:lower():find("kg") and buttonText:lower():find("age") then
                info = info .. " 🐾 ПИТОМЕЦ"
                addLog(info, Color3.fromRGB(100, 200, 255))
            else
                info = info .. " 📦 ПРЕДМЕТ"
                addLog(info, Color3.fromRGB(255, 200, 100))
            end
        else
            addLog(info, Color3.fromRGB(150, 150, 150))
        end
        
    else
        addLog(info, Color3.fromRGB(180, 180, 180))
    end
    
    -- Рекурсивно анализируем дочерние элементы (ограничиваем глубину)
    if depth < 4 then
        for _, child in pairs(element:GetChildren()) do
            if child:IsA("GuiObject") then
                analyzeGuiElement(child, depth + 1, path)
            end
        end
    end
end

-- Функция полного анализа
local function performFullAnalysis()
    clearLogs()
    addLog("🔍 Начинаю анализ структуры GUI...", Color3.fromRGB(0, 255, 255))
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then
        addLog("❌ PlayerGui не найден!", Color3.fromRGB(255, 0, 0))
        return
    end
    
    local backpackGui = playerGui:FindFirstChild("BackpackGui")
    if not backpackGui then
        addLog("❌ BackpackGui не найден!", Color3.fromRGB(255, 0, 0))
        return
    end
    
    addLog("✅ BackpackGui найден, анализирую структуру:", Color3.fromRGB(0, 255, 0))
    addLog("", Color3.white)
    
    -- Анализируем BackpackGui
    analyzeGuiElement(backpackGui, 0, "PlayerGui")
    
    addLog("", Color3.white)
    addLog("🎯 Анализ завершен! Ищите элементы с пометкой ⭐", Color3.fromRGB(0, 255, 255))
    addLog("📝 Основной инвентарь должен содержать 8-15 элементов и несколько кнопок", Color3.fromRGB(200, 200, 200))
end

-- Подключаем кнопку
analyzeButton.MouseButton1Click:Connect(function()
    performFullAnalysis()
end)

-- Автоматический анализ при запуске
wait(1)
performFullAnalysis()

addLog("", Color3.white)
addLog("🚀 InventoryStructureAnalyzer готов!", Color3.fromRGB(0, 255, 0))
addLog("💡 Нажмите кнопку для повторного анализа", Color3.fromRGB(200, 200, 200))
