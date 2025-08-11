-- TW2LOCK GUI Script for Roblox
-- Точная копия интерфейса с переключателями

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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
mainFrame.Size = UDim2.new(0, 280, 0, 160)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -80)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Скругленные углы для основного контейнера
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainFrame

-- Рамка контейнера
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(26, 26, 26)
mainStroke.Thickness = 3
mainStroke.Parent = mainFrame

-- Тень контейнера
local shadowFrame = Instance.new("Frame")
shadowFrame.Name = "Shadow"
shadowFrame.Size = UDim2.new(1, 10, 1, 10)
shadowFrame.Position = UDim2.new(0, -5, 0, 5)
shadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadowFrame.BackgroundTransparency = 0.7
shadowFrame.BorderSizePixel = 0
shadowFrame.ZIndex = mainFrame.ZIndex - 1
shadowFrame.Parent = mainFrame

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 18)
shadowCorner.Parent = shadowFrame

-- Заголовок (Header)
local headerFrame = Instance.new("Frame")
headerFrame.Name = "Header"
headerFrame.Size = UDim2.new(1, -16, 0, 40)
headerFrame.Position = UDim2.new(0, 8, 0, 8)
headerFrame.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
headerFrame.BorderSizePixel = 0
headerFrame.Parent = mainFrame

-- Скругленные углы заголовка
local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = headerFrame

-- Рамка заголовка
local headerStroke = Instance.new("UIStroke")
headerStroke.Color = Color3.fromRGB(56, 142, 60)
headerStroke.Thickness = 2
headerStroke.Parent = headerFrame

-- Градиент заголовка
local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(76, 175, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(69, 160, 73))
}
headerGradient.Rotation = 135
headerGradient.Parent = headerFrame

-- Заголовочный текст
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "TW2LOCK"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = headerFrame

-- Тень текста заголовка
local titleShadow = titleLabel:Clone()
titleShadow.Name = "TitleShadow"
titleShadow.Position = UDim2.new(0, 12, 0, 2)
titleShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
titleShadow.TextTransparency = 0.3
titleShadow.ZIndex = titleLabel.ZIndex - 1
titleShadow.Parent = headerFrame

-- Контент область
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -30, 0, 95)
contentFrame.Position = UDim2.new(0, 15, 0, 55)
contentFrame.BackgroundColor3 = Color3.fromRGB(61, 61, 61)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = contentFrame

-- Функция создания переключателя
function createToggleRow(name, displayText, position, initialState)
    -- Контейнер строки
    local rowFrame = Instance.new("Frame")
    rowFrame.Name = name .. "Row"
    rowFrame.Size = UDim2.new(1, -20, 0, 35)
    rowFrame.Position = position
    rowFrame.BackgroundColor3 = Color3.fromRGB(141, 110, 99)
    rowFrame.BorderSizePixel = 0
    rowFrame.Parent = contentFrame
    
    -- Скругленные углы строки
    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = rowFrame
    
    -- Рамка строки
    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = Color3.fromRGB(109, 76, 65)
    rowStroke.Thickness = 2
    rowStroke.Parent = rowFrame
    
    -- Градиент строки
    local rowGradient = Instance.new("UIGradient")
    rowGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(141, 110, 99)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(121, 85, 72))
    }
    rowGradient.Rotation = 135
    rowGradient.Parent = rowFrame
    
    -- Текст переключателя
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "Label"
    toggleLabel.Size = UDim2.new(0.7, -10, 1, 0)
    toggleLabel.Position = UDim2.new(0, 16, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = displayText
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.TextScaled = true
    toggleLabel.Font = Enum.Font.SourceSansBold
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = rowFrame
    
    -- Тень текста
    local labelShadow = toggleLabel:Clone()
    labelShadow.Name = "LabelShadow"
    labelShadow.Position = UDim2.new(0, 18, 0, 2)
    labelShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
    labelShadow.TextTransparency = 0.2
    labelShadow.ZIndex = toggleLabel.ZIndex - 1
    labelShadow.Parent = rowFrame
    
    -- Переключатель
    local toggleSwitch = Instance.new("Frame")
    toggleSwitch.Name = "Switch"
    toggleSwitch.Size = UDim2.new(0, 60, 0, 30)
    toggleSwitch.Position = UDim2.new(1, -70, 0.5, -15)
    toggleSwitch.BackgroundColor3 = initialState and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(66, 66, 66)
    toggleSwitch.BorderSizePixel = 0
    toggleSwitch.Parent = rowFrame
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0, 15)
    switchCorner.Parent = toggleSwitch
    
    local switchStroke = Instance.new("UIStroke")
    switchStroke.Color = initialState and Color3.fromRGB(56, 142, 60) or Color3.fromRGB(45, 45, 45)
    switchStroke.Thickness = 2
    switchStroke.Parent = toggleSwitch
    
    -- Слайдер переключателя
    local slider = Instance.new("Frame")
    slider.Name = "Slider"
    slider.Size = UDim2.new(0, 22, 0, 22)
    slider.Position = initialState and UDim2.new(1, -26, 0.5, -11) or UDim2.new(0, 4, 0.5, -11)
    slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    slider.BorderSizePixel = 0
    slider.Parent = toggleSwitch
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0.5, 0)
    sliderCorner.Parent = slider
    
    local sliderStroke = Instance.new("UIStroke")
    sliderStroke.Color = Color3.fromRGB(189, 189, 189)
    sliderStroke.Thickness = 1
    sliderStroke.Parent = slider
    
    -- Состояние переключателя
    local isToggled = initialState
    
    -- Функция переключения
    local function toggle()
        isToggled = not isToggled
        
        -- Анимация слайдера
        local sliderTween = TweenService:Create(slider, 
            TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), 
            {Position = isToggled and UDim2.new(1, -26, 0.5, -11) or UDim2.new(0, 4, 0.5, -11)}
        )
        
        -- Анимация цвета переключателя
        local switchTween = TweenService:Create(toggleSwitch,
            TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {BackgroundColor3 = isToggled and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(66, 66, 66)}
        )
        
        -- Анимация рамки переключателя
        local strokeTween = TweenService:Create(switchStroke,
            TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
            {Color = isToggled and Color3.fromRGB(56, 142, 60) or Color3.fromRGB(45, 45, 45)}
        )
        
        -- Анимация масштаба (эффект нажатия)
        local scaleDown = TweenService:Create(toggleSwitch,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 57, 0, 27)}
        )
        
        local scaleUp = TweenService:Create(toggleSwitch,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 60, 0, 30)}
        )
        
        scaleDown:Play()
        scaleDown.Completed:Connect(function()
            scaleUp:Play()
        end)
        
        sliderTween:Play()
        switchTween:Play()
        strokeTween:Play()
        
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
    
    clickDetector.MouseButton1Click:Connect(toggle)
    
    -- Hover эффект
    clickDetector.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(rowFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(151, 120, 109)}
        )
        hoverTween:Play()
    end)
    
    clickDetector.MouseLeave:Connect(function()
        local hoverTween = TweenService:Create(rowFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(141, 110, 99)}
        )
        hoverTween:Play()
    end)
    
    return {
        frame = rowFrame,
        toggle = toggle,
        getState = function() return isToggled end
    }
end

-- Создание переключателей
local freezeTradeToggle = createToggleRow("FreezeTrade", "FREEZE TRADE", UDim2.new(0, 10, 0, 10), true)
local autoAcceptToggle = createToggleRow("AutoAccept", "AUTO ACCEPT", UDim2.new(0, 10, 0, 50), true)

-- Кнопка помощи
local helpButton = Instance.new("TextButton")
helpButton.Name = "HelpButton"
helpButton.Size = UDim2.new(0, 35, 0, 35)
helpButton.Position = UDim2.new(1, -50, 1, -50)
helpButton.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
helpButton.BorderSizePixel = 0
helpButton.Text = "?"
helpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
helpButton.TextScaled = true
helpButton.Font = Enum.Font.SourceSansBold
helpButton.Parent = mainFrame

local helpCorner = Instance.new("UICorner")
helpCorner.CornerRadius = UDim.new(0.5, 0)
helpCorner.Parent = helpButton

local helpStroke = Instance.new("UIStroke")
helpStroke.Color = Color3.fromRGB(230, 81, 0)
helpStroke.Thickness = 3
helpStroke.Parent = helpButton

-- Градиент кнопки помощи
local helpGradient = Instance.new("UIGradient")
helpGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 152, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 124, 0))
}
helpGradient.Rotation = 135
helpGradient.Parent = helpButton

-- Тень текста кнопки помощи
local helpTextShadow = Instance.new("TextLabel")
helpTextShadow.Size = helpButton.Size
helpTextShadow.Position = UDim2.new(0, 1, 0, 1)
helpTextShadow.BackgroundTransparency = 1
helpTextShadow.Text = "?"
helpTextShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
helpTextShadow.TextTransparency = 0.5
helpTextShadow.TextScaled = true
helpTextShadow.Font = Enum.Font.SourceSansBold
helpTextShadow.ZIndex = helpButton.ZIndex - 1
helpTextShadow.Parent = helpButton

-- Обработчик кнопки помощи
helpButton.MouseButton1Click:Connect(function()
    -- Создаем простое уведомление
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 120)
    notification.Position = UDim2.new(0.5, -150, 0.5, -60)
    notification.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    notification.BorderSizePixel = 0
    notification.Parent = screenGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 15)
    notifCorner.Parent = notification
    
    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = Color3.fromRGB(255, 152, 0)
    notifStroke.Thickness = 2
    notifStroke.Parent = notification
    
    local helpText = Instance.new("TextLabel")
    helpText.Size = UDim2.new(1, -20, 0.7, 0)
    helpText.Position = UDim2.new(0, 10, 0, 10)
    helpText.BackgroundTransparency = 1
    helpText.Text = "TW2LOCK Settings:\n\nFREEZE TRADE: Prevents automatic trading\nAUTO ACCEPT: Automatically accepts trade requests"
    helpText.TextColor3 = Color3.fromRGB(255, 255, 255)
    helpText.TextScaled = true
    helpText.Font = Enum.Font.SourceSans
    helpText.TextWrapped = true
    helpText.Parent = notification
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 60, 0, 25)
    closeButton.Position = UDim2.new(0.5, -30, 0.8, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
    closeButton.Text = "OK"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.BorderSizePixel = 0
    closeButton.Parent = notification
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 5)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        notification:Destroy()
    end)
    
    -- Автоматически закрыть через 5 секунд
    game:GetService("Debris"):AddItem(notification, 5)
end)

-- Hover эффект для кнопки помощи
helpButton.MouseEnter:Connect(function()
    local hoverTween = TweenService:Create(helpButton,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 38, 0, 38), Position = UDim2.new(1, -51, 1, -51)}
    )
    hoverTween:Play()
end)

helpButton.MouseLeave:Connect(function()
    local hoverTween = TweenService:Create(helpButton,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 35, 0, 35), Position = UDim2.new(1, -50, 1, -50)}
    )
    hoverTween:Play()
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
    {Size = UDim2.new(0, 280, 0, 160)}
)
appearTween:Play()

print("TW2LOCK GUI успешно загружен!")
