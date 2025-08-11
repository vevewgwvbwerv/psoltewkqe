-- TW2LOCK Premium GUI Script for Roblox
-- Современный высококачественный интерфейс

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TW2LOCK_Premium_GUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Убираем затемнение экрана

-- Основной контейнер с современным дизайном (скорректированный размер)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainContainer"
mainFrame.Size = UDim2.new(0, 340, 0, 210)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -105)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Современные скругленные углы
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

-- Градиентная рамка
local borderFrame = Instance.new("Frame")
borderFrame.Size = UDim2.new(1, 4, 1, 4)
borderFrame.Position = UDim2.new(0, -2, 0, -2)
borderFrame.BackgroundTransparency = 1
borderFrame.BorderSizePixel = 0
borderFrame.ZIndex = mainFrame.ZIndex - 1
borderFrame.Parent = mainFrame

local borderStroke = Instance.new("UIStroke")
borderStroke.Thickness = 2
borderStroke.Color = Color3.fromRGB(100, 200, 255)
borderStroke.Transparency = 0.3
borderStroke.Parent = mainFrame

local borderGradient = Instance.new("UIGradient")
borderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 150))
}
borderGradient.Rotation = 45
borderGradient.Parent = borderStroke

-- Заголовок с градиентом
local headerFrame = Instance.new("Frame")
headerFrame.Name = "Header"
headerFrame.Size = UDim2.new(1, 0, 0, 50)
headerFrame.Position = UDim2.new(0, 0, 0, 0)
headerFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
headerFrame.BorderSizePixel = 0
headerFrame.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = headerFrame

local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 50))
}
headerGradient.Rotation = 90
headerGradient.Parent = headerFrame

-- Заголовочный текст с эффектами
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 20, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "TW2LOCK"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = headerFrame

-- Светящийся эффект для заголовка
local titleGlow = titleLabel:Clone()
titleGlow.Name = "TitleGlow"
titleGlow.Position = UDim2.new(0, 22, 0, 2)
titleGlow.TextColor3 = Color3.fromRGB(100, 200, 255)
titleGlow.TextTransparency = 0.7
titleGlow.ZIndex = titleLabel.ZIndex - 1
titleGlow.Parent = headerFrame

-- Функция создания идеального премиум тумблера
local function createPremiumToggle(name, displayText, yPosition, initialState)
    -- Контейнер строки с современным дизайном
    local rowFrame = Instance.new("Frame")
    rowFrame.Name = name .. "Row"
    rowFrame.Size = UDim2.new(1, -40, 0, 60)
    rowFrame.Position = UDim2.new(0, 20, 0, yPosition)
    rowFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    rowFrame.BorderSizePixel = 0
    rowFrame.Parent = mainFrame
    
    -- Скругленные углы для строки
    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 12)
    rowCorner.Parent = rowFrame
    
    -- Тонкая светящаяся рамка
    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = Color3.fromRGB(60, 60, 80)
    rowStroke.Thickness = 1
    rowStroke.Transparency = 0.5
    rowStroke.Parent = rowFrame
    
    -- Градиентный фон
    local rowGradient = Instance.new("UIGradient")
    rowGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 45))
    }
    rowGradient.Rotation = 90
    rowGradient.Parent = rowFrame
    
    -- Текст переключателя с современным шрифтом
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "Label"
    toggleLabel.Size = UDim2.new(0, 200, 1, 0)
    toggleLabel.Position = UDim2.new(0, 20, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = displayText
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.TextSize = 18
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.TextYAlignment = Enum.TextYAlignment.Center
    toggleLabel.Parent = rowFrame
    
    -- Светящийся эффект для текста
    local labelGlow = toggleLabel:Clone()
    labelGlow.Name = "LabelGlow"
    labelGlow.Position = UDim2.new(0, 22, 0, 2)
    labelGlow.TextColor3 = initialState and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(100, 100, 150)
    labelGlow.TextTransparency = 0.8
    labelGlow.ZIndex = toggleLabel.ZIndex - 1
    labelGlow.Parent = rowFrame
    
    -- Идеальный тумблер в стиле iOS с неоновыми цветами
    local toggleTrack = Instance.new("Frame")
    toggleTrack.Name = "ToggleTrack"
    toggleTrack.Size = UDim2.new(0, 70, 0, 35)
    toggleTrack.Position = UDim2.new(1, -90, 0.5, -17.5)
    toggleTrack.BackgroundColor3 = initialState and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(80, 80, 100)
    toggleTrack.BorderSizePixel = 0
    toggleTrack.Parent = rowFrame
    
    -- Скругленные углы для трека
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0.5, 0)
    trackCorner.Parent = toggleTrack
    
    -- Неоновая рамка трека
    local trackStroke = Instance.new("UIStroke")
    trackStroke.Color = initialState and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(60, 60, 80)
    trackStroke.Thickness = 2
    trackStroke.Transparency = initialState and 0.3 or 0.8
    trackStroke.Parent = toggleTrack
    
    -- Неоновый градиент для трека (как у рамки GUI)
    local trackGradient = Instance.new("UIGradient")
    trackGradient.Color = initialState and ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 100, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 150))
    } or ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 100, 120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 80))
    }
    trackGradient.Rotation = 45
    trackGradient.Parent = toggleTrack
    
    -- Градиент для рамки трека
    local trackStrokeGradient = Instance.new("UIGradient")
    trackStrokeGradient.Color = initialState and ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 100, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 150))
    } or ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 80))
    }
    trackStrokeGradient.Rotation = 45
    trackStrokeGradient.Parent = trackStroke
    
    -- Слайдер (кнопка)
    local slider = Instance.new("Frame")
    slider.Name = "Slider"
    slider.Size = UDim2.new(0, 29, 0, 29)
    slider.Position = initialState and UDim2.new(1, -32, 0.5, -14.5) or UDim2.new(0, 3, 0.5, -14.5)
    slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    slider.BorderSizePixel = 0
    slider.Parent = toggleTrack
    
    -- Скругленный слайдер
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0.5, 0)
    sliderCorner.Parent = slider
    
    -- Тень слайдера
    local sliderStroke = Instance.new("UIStroke")
    sliderStroke.Color = Color3.fromRGB(0, 0, 0)
    sliderStroke.Thickness = 1
    sliderStroke.Transparency = 0.9
    sliderStroke.Parent = slider
    
    -- Градиент слайдера
    local sliderGradient = Instance.new("UIGradient")
    sliderGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 240, 240))
    }
    sliderGradient.Rotation = 90
    sliderGradient.Parent = slider
    
    -- Состояние переключателя
    local isToggled = initialState
    
    -- Функция переключения с потрясающими анимациями
    local function toggle()
        isToggled = not isToggled
        
        -- Анимация слайдера
        local sliderTween = TweenService:Create(slider, 
            TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
            {Position = newState and UDim2.new(1, -32, 0.5, -14.5) or UDim2.new(0, 3, 0.5, -14.5)}
        )
        
        -- Анимация трека с неоновыми цветами
        local trackColorTween = TweenService:Create(toggleTrack,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = newState and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(80, 80, 100)}
        )
        
        -- Анимация рамки трека
        local strokeColorTween = TweenService:Create(trackStroke,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                Color = newState and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(60, 60, 80),
                Transparency = newState and 0.3 or 0.8
            }
        )
        
        -- Анимация неонового градиента трека
        local newTrackGradient = newState and ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 100, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 150))
        } or ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 100, 120)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 80))
        }
        
        local gradientTween = TweenService:Create(trackGradient,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Color = newTrackGradient}
        )
        
        -- Анимация градиента рамки трека
        local newStrokeGradient = newState and ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 100, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 150))
        } or ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 80)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 80))
        }
        
        local strokeGradientTween = TweenService:Create(trackStrokeGradient,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Color = newStrokeGradient}
        )
        
        -- Анимация свечения текста
        local glowTween = TweenService:Create(labelGlow,
            TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {TextColor3 = newState and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(100, 100, 150)}
        )
        
        -- Анимация рамки строки
        local strokeTween = TweenService:Create(rowStroke,
            TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Color = newState and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(60, 60, 80)}
        )
        
        -- Эффект пульсации при переключении
        local pulseScale = TweenService:Create(slider,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 33, 0, 33)}
        )
        
        local pulseBack = TweenService:Create(slider,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 29, 0, 29)}
        )
        
        -- Запуск всех анимаций
        sliderTween:Play()
        trackTween:Play()
        glowTween:Play()
        strokeTween:Play()
        pulseScale:Play()
        
        pulseScale.Completed:Connect(function()
            pulseBack:Play()
        end)
        
        -- Обновляем градиент
        trackGradient.Color = newGradient
        
        -- Консольный вывод
        print(displayText .. ": " .. (isToggled and "ENABLED" or "DISABLED"))
        
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
    
    -- Hover эффекты
    clickDetector.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(rowFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(45, 45, 65)}
        )
        hoverTween:Play()
    end)
    
    clickDetector.MouseLeave:Connect(function()
        local hoverTween = TweenService:Create(rowFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}
        )
        hoverTween:Play()
    end)
    
    return {
        frame = rowFrame,
        toggle = toggle,
        getState = function() return isToggled end
    }
end

-- Создание премиум переключателей (изначально выключены)
local freezeTradeToggle = createPremiumToggle("FreezeTrade", "FREEZE TRADE", 65, false)
local autoAcceptToggle = createPremiumToggle("AutoAccept", "AUTO ACCEPT", 135, false)

-- Сделать интерфейс перетаскиваемым с плавными эффектами
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
        
        -- Эффект нажатия
        local pressEffect = TweenService:Create(headerFrame,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(55, 55, 70)}
        )
        pressEffect:Play()
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                -- Возврат к нормальному цвету
                local releaseEffect = TweenService:Create(headerFrame,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundColor3 = Color3.fromRGB(45, 45, 60)}
                )
                releaseEffect:Play()
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

-- Потрясающая анимация появления GUI
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundTransparency = 1

-- Анимация появления основного контейнера
local sizeAppear = TweenService:Create(mainFrame,
    TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Size = UDim2.new(0, 340, 0, 210)}
)

local fadeAppear = TweenService:Create(mainFrame,
    TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {BackgroundTransparency = 0}
)

-- Анимация градиентной рамки
local borderRotation = TweenService:Create(borderGradient,
    TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
    {Rotation = 405}
)

-- Запуск анимаций
sizeAppear:Play()
fadeAppear:Play()
wait(0.5)
borderRotation:Play()

-- Анимация пульсации заголовка
local function pulseTitle()
    local pulseTween = TweenService:Create(titleGlow,
        TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {TextTransparency = 0.4}
    )
    pulseTween:Play()
end

pulseTitle()

print("🚀 TW2LOCK Premium GUI успешно загружен! 🚀")
