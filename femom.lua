-- GuiEventAnalyzer.lua
-- Анализатор событий GUI для изучения механизма выбора питомца

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Создаем компактный GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GuiEventAnalyzer"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Главный фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.8, 0, 0.4, 0)
mainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.2, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "🔍 GUI Event Analyzer"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

-- Текст с инструкцией
local instructionLabel = Instance.new("TextLabel")
instructionLabel.Size = UDim2.new(1, 0, 0.3, 0)
instructionLabel.Position = UDim2.new(0, 0, 0.2, 0)
instructionLabel.BackgroundTransparency = 1
instructionLabel.Text = "Нажмите 'Старт', затем кликните по Dragonfly в инвентаре.\nСкрипт покажет, какие события происходят."
instructionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
instructionLabel.TextScaled = true
instructionLabel.Font = Enum.Font.SourceSans
instructionLabel.TextWrapped = true
instructionLabel.Parent = mainFrame

-- Кнопка старта
local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0.4, 0, 0.25, 0)
startButton.Position = UDim2.new(0.05, 0, 0.55, 0)
startButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
startButton.BorderSizePixel = 0
startButton.Text = "🚀 Старт Анализа"
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.TextScaled = true
startButton.Font = Enum.Font.SourceSansBold
startButton.Parent = mainFrame

-- Кнопка стопа
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0.4, 0, 0.25, 0)
startButton.Position = UDim2.new(0.55, 0, 0.55, 0)
stopButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
stopButton.BorderSizePixel = 0
stopButton.Text = "⏹️ Стоп"
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.TextScaled = true
stopButton.Font = Enum.Font.SourceSansBold
stopButton.Parent = mainFrame

-- Статус
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0.2, 0)
statusLabel.Position = UDim2.new(0, 0, 0.8, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Готов к анализу"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Parent = mainFrame

-- Переменные для анализа
local isAnalyzing = false
local connections = {}

-- Функция подключения событий к элементу
local function connectEvents(element)
    if not element:IsA("GuiObject") then return end
    
    local elementName = element.Name .. " (" .. element.ClassName .. ")"
    
    -- Подключаем все возможные события
    local eventTypes = {
        "MouseButton1Click",
        "MouseButton1Down", 
        "MouseButton1Up",
        "MouseButton2Click",
        "MouseEnter",
        "MouseLeave",
        "InputBegan",
        "InputEnded",
        "Activated"
    }
    
    for _, eventName in pairs(eventTypes) do
        local success, event = pcall(function()
            return element[eventName]
        end)
        
        if success and event then
            local connection = event:Connect(function(...)
                local args = {...}
                local argString = ""
                
                if #args > 0 then
                    for i, arg in pairs(args) do
                        argString = argString .. tostring(arg)
                        if i < #args then
                            argString = argString .. ", "
                        end
                    end
                end
                
                print("🎯 СОБЫТИЕ:", eventName, "на", elementName)
                if argString ~= "" then
                    print("   📋 Аргументы:", argString)
                end
                
                -- Особое внимание к Dragonfly
                if element.Name == "23" or (element.Parent and element.Parent.Name == "23") then
                    print("🐉 *** ЭТО DRAGONFLY ЭЛЕМЕНТ! ***")
                end
            end)
            
            table.insert(connections, connection)
        end
    end
end

-- Функция поиска и подключения к Dragonfly элементам
local function findAndConnectDragonfly()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    local backpackGui = playerGui:FindFirstChild("BackpackGui")
    if not backpackGui then return end
    
    print("🔍 Подключаюсь к событиям Dragonfly элементов...")
    
    -- Ищем все элементы, связанные с Dragonfly
    for _, desc in pairs(backpackGui:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Text:lower():find("dragonfly") then
            print("🐾 Найден Dragonfly текст:", desc.Text)
            
            -- Подключаемся к родительскому элементу
            if desc.Parent then
                print("   🔗 Подключаюсь к родителю:", desc.Parent.Name, "(" .. desc.Parent.ClassName .. ")")
                connectEvents(desc.Parent)
                
                -- И ко всем дочерним элементам
                for _, child in pairs(desc.Parent:GetChildren()) do
                    if child:IsA("GuiObject") then
                        print("   🔗 Подключаюсь к дочернему:", child.Name, "(" .. child.ClassName .. ")")
                        connectEvents(child)
                    end
                end
            end
        end
    end
end

-- Функция старта анализа
local function startAnalysis()
    if isAnalyzing then return end
    
    isAnalyzing = true
    startButton.Text = "⏳ Анализирую..."
    startButton.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
    statusLabel.Text = "🔍 Анализ запущен - кликните по Dragonfly"
    
    -- Отключаем старые соединения
    for _, connection in pairs(connections) do
        connection:Disconnect()
    end
    connections = {}
    
    -- Подключаемся к Dragonfly элементам
    findAndConnectDragonfly()
    
    print("✅ Анализ событий запущен! Кликните по Dragonfly в инвентаре.")
end

-- Функция остановки анализа
local function stopAnalysis()
    if not isAnalyzing then return end
    
    isAnalyzing = false
    startButton.Text = "🚀 Старт Анализа"
    startButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    statusLabel.Text = "⏹️ Анализ остановлен"
    
    -- Отключаем все соединения
    for _, connection in pairs(connections) do
        connection:Disconnect()
    end
    connections = {}
    
    print("⏹️ Анализ событий остановлен")
end

-- Обработчики кнопок
startButton.MouseButton1Click:Connect(function()
    startAnalysis()
end)

stopButton.MouseButton1Click:Connect(function()
    stopAnalysis()
end)

print("✅ GuiEventAnalyzer загружен! Нажмите 'Старт', затем кликните по Dragonfly.")
