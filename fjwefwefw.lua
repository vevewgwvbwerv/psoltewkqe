-- TW2LOCK GUI Script for Roblox
-- Minecraft/Lego стиль интерфейса с переключателями

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TW2LOCK_GUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Основной контейнер
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainContainer"
mainFrame.Size = UDim2.new(0, 300, 0, 140)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -70)
mainFrame.BackgroundColor3 = Color3.fromRGB(139, 69, 19) -- Коричневый как на картинке
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(101, 50, 14)
mainFrame.Parent = screenGui

-- Заголовок (Header)
local headerFrame = Instance.new("Frame")
headerFrame.Name = "Header"
headerFrame.Size = UDim2.new(1, 0, 0, 35)
headerFrame.Position = UDim2.new(0, 0, 0, 0)
headerFrame.BackgroundColor3 = Color3.fromRGB(76, 175, 80) -- Зеленый как на картинке
headerFrame.BorderSizePixel = 2
headerFrame.BorderColor3 = Color3.fromRGB(56, 142, 60)
headerFrame.Parent = mainFrame

-- Заголовочный текст
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 5, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "TW2LOCK"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = headerFrame

-- Функция создания переключателя в стиле Lego блоков
local function createToggleRow(name, displayText, yPosition, initialState)
    -- Контейнер строки с текстурой Lego
    local rowFrame = Instance.new("Frame")
    rowFrame.Name = name .. "Row"
    rowFrame.Size = UDim2.new(1, -20, 0, 40)
    rowFrame.Position = UDim2.new(0, 10, 0, yPosition)
    rowFrame.BackgroundColor3 = Color3.fromRGB(139, 69, 19) -- Коричневый фон как Lego блок
    rowFrame.BorderSizePixel = 2
    rowFrame.BorderColor3 = Color3.fromRGB(101, 50, 14)
    rowFrame.Parent = mainFrame
    
    -- Создаем текстуру Lego блока (маленькие круглые выступы)
    for i = 1, 8 do
        local legoStud = Instance.new("Frame")
        legoStud.Size = UDim2.new(0, 8, 0, 8)
        legoStud.Position = UDim2.new(0, 10 + (i-1) * 15, 0.5, -4)
        legoStud.BackgroundColor3 = Color3.fromRGB(160, 82, 25) -- Светлее основного цвета
        legoStud.BorderSizePixel = 1
        legoStud.BorderColor3 = Color3.fromRGB(101, 50, 14)
        legoStud.Parent = rowFrame
        
        -- Делаем круглыми
        local studCorner = Instance.new("UICorner")
        studCorner.CornerRadius = UDim.new(0.5, 0)
        studCorner.Parent = legoStud
    end
    
    -- Текст переключателя
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "Label"
    toggleLabel.Size = UDim2.new(0, 150, 1, 0)
    toggleLabel.Position = UDim2.new(0, 15, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = displayText
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.TextSize = 14
    toggleLabel.Font = Enum.Font.SourceSansBold
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.TextYAlignment = Enum.TextYAlignment.Center
    toggleLabel.Parent = rowFrame
    
    -- Переключатель в стиле круглого Lego элемента
    local toggleSwitch = Instance.new("Frame")
    toggleSwitch.Name = "Switch"
    toggleSwitch.Size = UDim2.new(0, 60, 0, 30)
    toggleSwitch.Position = UDim2.new(1, -70, 0.5, -15)
    toggleSwitch.BackgroundColor3 = initialState and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(160, 160, 160)
    toggleSwitch.BorderSizePixel = 2
    toggleSwitch.BorderColor3 = Color3.fromRGB(0, 0, 0)
    toggleSwitch.Parent = rowFrame
    
    -- Скругляем переключатель
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0, 15)
    switchCorner.Parent = toggleSwitch
    
    -- Круглый слайдер как Lego кнопка
    local slider = Instance.new("Frame")
    slider.Name = "Slider"
    slider.Size = UDim2.new(0, 24, 0, 24)
    slider.Position = initialState and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
    slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    slider.BorderSizePixel = 2
    slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
    slider.Parent = toggleSwitch
    
    -- Делаем слайдер круглым
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0.5, 0)
    sliderCorner.Parent = slider
    
    -- Добавляем центральную точку на слайдер (как на Lego кнопке)
    local centerDot = Instance.new("Frame")
    centerDot.Size = UDim2.new(0, 8, 0, 8)
    centerDot.Position = UDim2.new(0.5, -4, 0.5, -4)
    centerDot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    centerDot.BorderSizePixel = 1
    centerDot.BorderColor3 = Color3.fromRGB(150, 150, 150)
    centerDot.Parent = slider
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0.5, 0)
    dotCorner.Parent = centerDot
    
    -- Состояние переключателя
    local isToggled = initialState
    
    -- Функция переключения
    local function toggle()
        isToggled = not isToggled
        
        -- Анимация слайдера
        local sliderTween = TweenService:Create(slider, 
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {Position = isToggled and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)}
        )
        
        -- Анимация цвета переключателя
        local switchTween = TweenService:Create(toggleSwitch,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = isToggled and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(160, 160, 160)}
        )
        
        sliderTween:Play()
        switchTween:Play()
        
        -- Консольный вывод для демонстрации
        print(displayText .. ": " .. (isToggled and "ON" or "OFF"))
        
        return isToggled
    end
    
    -- Обработчик клика
    local clickDetector = Instance.new("TextButton")
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ""
    clickDetector.Parent = rowFrame
    
    clickDetector.MouseButton1Click:Connect(function()
        toggle()
    end)
    
    return {
        frame = rowFrame,
        toggle = toggle,
        getState = function() return isToggled end
    }
end

-- Создание переключателей
local freezeTradeToggle = createToggleRow("FreezeTrade", "FREEZE TRADE", 45, true)
local autoAcceptToggle = createToggleRow("AutoAccept", "AUTO ACCEPT", 85, true)

-- Кнопка помощи
local helpButton = Instance.new("TextButton")
helpButton.Name = "HelpButton"
helpButton.Size = UDim2.new(0, 25, 0, 25)
helpButton.Position = UDim2.new(1, -35, 1, -35)
helpButton.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
helpButton.BorderSizePixel = 2
helpButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
helpButton.Text = "?"
helpButton.TextColor3 = Color3.fromRGB(0, 0, 0)
helpButton.TextSize = 16
helpButton.Font = Enum.Font.SourceSansBold
helpButton.Parent = mainFrame

-- Обработчик кнопки помощи
helpButton.MouseButton1Click:Connect(function()
    -- Создаем простое уведомление
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 120)
    notification.Position = UDim2.new(0.5, -150, 0.5, -60)
    notification.BackgroundColor3 = Color3.fromRGB(139, 69, 19)
    notification.BorderSizePixel = 2
    notification.BorderColor3 = Color3.fromRGB(101, 50, 14)
    notification.Parent = screenGui
    
    local helpText = Instance.new("TextLabel")
    helpText.Size = UDim2.new(1, -20, 0.7, 0)
    helpText.Position = UDim2.new(0, 10, 0, 10)
    helpText.BackgroundTransparency = 1
    helpText.Text = "TW2LOCK Settings\n\nFREEZE TRADE: Prevents automatic trading\nAUTO ACCEPT: Automatically accepts trade requests"
    helpText.TextColor3 = Color3.fromRGB(255, 255, 255)
    helpText.TextSize = 14
    helpText.Font = Enum.Font.SourceSans
    helpText.TextWrapped = true
    helpText.TextYAlignment = Enum.TextYAlignment.Top
    helpText.Parent = notification
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 60, 0, 25)
    closeButton.Position = UDim2.new(0.5, -30, 0.8, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
    closeButton.BorderSizePixel = 2
    closeButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    closeButton.Text = "OK"
    closeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = notification
    
    closeButton.MouseButton1Click:Connect(function()
        notification:Destroy()
    end)
    
    -- Автоматически закрыть через 5 секунд
    game:GetService("Debris"):AddItem(notification, 5)
end)

-- Сделать интерфейс перетаскиваемым
local dragging = false
local dragStart = nil
local startPos = nil

local function updateInput(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

headerFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

headerFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if dragging then
            updateInput(input)
        end
    end
end)

-- Анимация появления GUI
mainFrame.Size = UDim2.new(0, 0, 0, 0)
local appearTween = TweenService:Create(mainFrame,
    TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Size = UDim2.new(0, 300, 0, 140)}
)
appearTween:Play()

print("TW2LOCK GUI успешно загружен!")
