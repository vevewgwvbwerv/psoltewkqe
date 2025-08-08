-- MainInventoryFinder.lua
-- Поиск основного инвентаря (горизонтальная полоса с 10 слотами)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Создаем компактный GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainInventoryFinder"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Главный фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.9, 0, 0.6, 0)
mainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.15, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "🎯 Поиск Основного Инвентаря"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

-- Скролл фрейм для логов
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 0.65, 0)
scrollFrame.Position = UDim2.new(0, 10, 0.15, 0)
scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = mainFrame

-- Текст для логов
local logText = Instance.new("TextLabel")
logText.Size = UDim2.new(1, -10, 1, 0)
logText.Position = UDim2.new(0, 5, 0, 0)
logText.BackgroundTransparency = 1
logText.Text = "Нажмите кнопку для поиска основного инвентаря..."
logText.TextColor3 = Color3.fromRGB(255, 255, 255)
logText.TextXAlignment = Enum.TextXAlignment.Left
logText.TextYAlignment = Enum.TextYAlignment.Top
logText.TextWrapped = true
logText.Font = Enum.Font.SourceSans
logText.TextSize = 12
logText.Parent = scrollFrame

-- Кнопки
local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(1, 0, 0.2, 0)
buttonFrame.Position = UDim2.new(0, 0, 0.8, 0)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = mainFrame

-- Кнопка поиска основного инвентаря
local findMainButton = Instance.new("TextButton")
findMainButton.Size = UDim2.new(0.4, -5, 0.7, 0)
findMainButton.Position = UDim2.new(0.05, 0, 0.15, 0)
findMainButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
findMainButton.BorderSizePixel = 0
findMainButton.Text = "🔍 Найти Основной Инвентарь"
findMainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
findMainButton.TextScaled = true
findMainButton.Font = Enum.Font.SourceSansBold
findMainButton.Parent = buttonFrame

-- Кнопка очистки
local clearButton = Instance.new("TextButton")
clearButton.Size = UDim2.new(0.4, -5, 0.7, 0)
clearButton.Position = UDim2.new(0.55, 0, 0.15, 0)
clearButton.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
clearButton.BorderSizePixel = 0
clearButton.Text = "🗑️ Очистить"
clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearButton.TextScaled = true
clearButton.Font = Enum.Font.SourceSansBold
clearButton.Parent = buttonFrame

-- Переменные
local logs = {}

-- Функция добавления лога
local function addLog(message)
    table.insert(logs, os.date("[%H:%M:%S] ") .. message)
    if #logs > 100 then
        table.remove(logs, 1)
    end
    
    logText.Text = table.concat(logs, "\n")
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, logText.TextBounds.Y + 20)
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
end

-- Функция поиска основного инвентаря
local function findMainInventory()
    addLog("🔍 === ПОИСК ОСНОВНОГО ИНВЕНТАРЯ ===")
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then
        addLog("❌ PlayerGui не найден")
        return
    end
    
    local candidates = {}
    
    -- Ищем горизонтальные контейнеры с питомцами
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "MainInventoryFinder" then
            addLog("📱 Сканирую GUI: " .. gui.Name)
            
            for _, frame in pairs(gui:GetDescendants()) do
                if frame:IsA("Frame") or frame:IsA("ScrollingFrame") then
                    -- Ищем горизонтальные контейнеры
                    local children = frame:GetChildren()
                    local horizontalSlots = 0
                    local petSlots = 0
                    
                    -- Проверяем расположение дочерних элементов
                    local positions = {}
                    for _, child in pairs(children) do
                        if child:IsA("GuiObject") and child.Visible then
                            table.insert(positions, {
                                x = child.AbsolutePosition.X,
                                y = child.AbsolutePosition.Y,
                                element = child
                            })
                        end
                    end
                    
                    -- Сортируем по X координате
                    table.sort(positions, function(a, b) return a.x < b.x end)
                    
                    -- Проверяем, расположены ли элементы горизонтально
                    if #positions >= 8 then
                        local isHorizontal = true
                        local avgY = positions[1].y
                        
                        for i = 2, math.min(10, #positions) do
                            if math.abs(positions[i].y - avgY) > 50 then
                                isHorizontal = false
                                break
                            end
                        end
                        
                        if isHorizontal then
                            horizontalSlots = #positions
                            
                            -- Проверяем наличие питомцев в слотах
                            for _, pos in pairs(positions) do
                                local hasPet = false
                                for _, desc in pairs(pos.element:GetDescendants()) do
                                    if desc:IsA("TextLabel") and (
                                        desc.Text:lower():find("kg") or 
                                        desc.Text:lower():find("age") or
                                        desc.Text:lower():find("dog") or
                                        desc.Text:lower():find("bunny") or
                                        desc.Text:lower():find("golden") or
                                        desc.Text:lower():find("chicken") or
                                        desc.Text:lower():find("shovel")
                                    ) then
                                        hasPet = true
                                        petSlots = petSlots + 1
                                        addLog("🐾 Слот " .. petSlots .. ": " .. desc.Text)
                                        break
                                    end
                                end
                            end
                            
                            -- Если найдено 8-12 горизонтальных слотов, это кандидат
                            if horizontalSlots >= 8 and horizontalSlots <= 12 then
                                table.insert(candidates, {
                                    gui = gui.Name,
                                    frame = frame.Name,
                                    frameType = frame.ClassName,
                                    slots = horizontalSlots,
                                    pets = petSlots,
                                    position = {x = frame.AbsolutePosition.X, y = frame.AbsolutePosition.Y},
                                    size = {x = frame.AbsoluteSize.X, y = frame.AbsoluteSize.Y},
                                    frame_obj = frame
                                })
                                
                                addLog("🎯 КАНДИДАТ НА ОСНОВНОЙ ИНВЕНТАРЬ:")
                                addLog("   📱 GUI: " .. gui.Name)
                                addLog("   📋 Фрейм: " .. frame.Name .. " (" .. frame.ClassName .. ")")
                                addLog("   🎯 Слотов: " .. horizontalSlots)
                                addLog("   🐾 Питомцев: " .. petSlots)
                                addLog("   📍 Позиция: " .. frame.AbsolutePosition.X .. ", " .. frame.AbsolutePosition.Y)
                                addLog("   📏 Размер: " .. frame.AbsoluteSize.X .. " x " .. frame.AbsoluteSize.Y)
                                addLog("")
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Анализируем кандидатов
    if #candidates == 0 then
        addLog("❌ Основной инвентарь не найден")
        addLog("💡 Убедитесь, что основной инвентарь виден на экране")
    else
        addLog("📊 === РЕЗУЛЬТАТЫ ПОИСКА ===")
        addLog("🎯 Найдено кандидатов: " .. #candidates)
        
        -- Выбираем лучшего кандидата (с наибольшим количеством питомцев)
        local bestCandidate = candidates[1]
        for _, candidate in pairs(candidates) do
            if candidate.pets > bestCandidate.pets then
                bestCandidate = candidate
            end
        end
        
        addLog("🏆 ЛУЧШИЙ КАНДИДАТ:")
        addLog("   📱 GUI: " .. bestCandidate.gui)
        addLog("   📋 Фрейм: " .. bestCandidate.frame)
        addLog("   🎯 Слотов: " .. bestCandidate.slots)
        addLog("   🐾 Питомцев: " .. bestCandidate.pets)
        addLog("   📍 Позиция: " .. bestCandidate.position.x .. ", " .. bestCandidate.position.y)
        
        -- Сохраняем информацию для дальнейшего использования
        _G.MainInventoryInfo = bestCandidate
        addLog("💾 Информация сохранена в _G.MainInventoryInfo")
        
        -- Анализируем структуру слотов
        addLog("")
        addLog("🔍 === АНАЛИЗ СТРУКТУРЫ СЛОТОВ ===")
        local slots = bestCandidate.frame_obj:GetChildren()
        for i, slot in pairs(slots) do
            if slot:IsA("GuiObject") and slot.Visible then
                addLog("📦 Слот " .. i .. ":")
                addLog("   📛 Имя: " .. slot.Name)
                addLog("   🏷️ Тип: " .. slot.ClassName)
                addLog("   📍 Позиция: " .. slot.AbsolutePosition.X .. ", " .. slot.AbsolutePosition.Y)
                
                -- Ищем пустые слоты
                local isEmpty = true
                for _, desc in pairs(slot:GetDescendants()) do
                    if desc:IsA("TextLabel") and desc.Text ~= "" and (
                        desc.Text:lower():find("kg") or 
                        desc.Text:lower():find("age")
                    ) then
                        isEmpty = false
                        break
                    end
                end
                
                if isEmpty then
                    addLog("   ✅ ПУСТОЙ СЛОТ - можно использовать для Dragonfly!")
                end
            end
        end
    end
end

-- Обработчики кнопок
findMainButton.MouseButton1Click:Connect(function()
    findMainInventory()
end)

clearButton.MouseButton1Click:Connect(function()
    logs = {}
    logText.Text = "Логи очищены..."
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

-- Начальное сообщение
addLog("🚀 Поиск основного инвентаря запущен!")
addLog("🎯 Ищем горизонтальную полоску с 8-12 слотами для питомцев")
addLog("📱 Нажмите 'Найти Основной Инвентарь' для начала поиска")

print("✅ MainInventoryFinder загружен! Найдет основной инвентарь.")
