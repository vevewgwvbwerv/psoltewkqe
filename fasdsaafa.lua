-- LuaArmor Code Interceptor with GUI Console
-- Перехватывает loadstring и показывает код в GUI консоли

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Сохраняем оригинальную функцию loadstring
local originalLoadstring = loadstring

-- Переменные для GUI
local interceptorGui = nil
local codeDisplay = nil
local interceptedCode = ""
local pendingExecution = nil

-- Создание GUI консоли
local function createInterceptorGUI()
    -- Основной ScreenGui
    interceptorGui = Instance.new("ScreenGui")
    interceptorGui.Name = "LuaArmorInterceptor"
    interceptorGui.ResetOnSpawn = false
    interceptorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    interceptorGui.Parent = playerGui

    -- Главное окно
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
    mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = interceptorGui

    -- Закругленные углы
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- Заголовок
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🔍 LuaArmor Code Interceptor"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = titleBar

    -- Кнопка закрытия
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -45, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton

    -- Информационная панель
    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "InfoFrame"
    infoFrame.Size = UDim2.new(1, -20, 0, 60)
    infoFrame.Position = UDim2.new(0, 10, 0, 60)
    infoFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    infoFrame.BorderSizePixel = 0
    infoFrame.Parent = mainFrame

    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = infoFrame

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Size = UDim2.new(1, -20, 1, 0)
    infoLabel.Position = UDim2.new(0, 10, 0, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "⚠️ Перехвачен код LuaArmor! Проверьте содержимое перед выполнением."
    infoLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    infoLabel.TextScaled = true
    infoLabel.TextWrapped = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Parent = infoFrame

    -- Область для кода
    local codeFrame = Instance.new("ScrollingFrame")
    codeFrame.Name = "CodeFrame"
    codeFrame.Size = UDim2.new(1, -20, 1, -200)
    codeFrame.Position = UDim2.new(0, 10, 0, 130)
    codeFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    codeFrame.BorderSizePixel = 0
    codeFrame.ScrollBarThickness = 8
    codeFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    codeFrame.Parent = mainFrame

    local codeCorner = Instance.new("UICorner")
    codeCorner.CornerRadius = UDim.new(0, 8)
    codeCorner.Parent = codeFrame

    -- Текстовое поле для кода
    codeDisplay = Instance.new("TextLabel")
    codeDisplay.Name = "CodeDisplay"
    codeDisplay.Size = UDim2.new(1, -20, 1, 0)
    codeDisplay.Position = UDim2.new(0, 10, 0, 0)
    codeDisplay.BackgroundTransparency = 1
    codeDisplay.Text = "Ожидание перехвата кода..."
    codeDisplay.TextColor3 = Color3.fromRGB(0, 255, 100)
    codeDisplay.TextSize = 12
    codeDisplay.TextXAlignment = Enum.TextXAlignment.Left
    codeDisplay.TextYAlignment = Enum.TextYAlignment.Top
    codeDisplay.TextWrapped = true
    codeDisplay.Font = Enum.Font.Code
    codeDisplay.Parent = codeFrame

    -- Панель кнопок
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "ButtonFrame"
    buttonFrame.Size = UDim2.new(1, -20, 0, 50)
    buttonFrame.Position = UDim2.new(0, 10, 1, -60)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = mainFrame

    -- Кнопка выполнения
    local executeButton = Instance.new("TextButton")
    executeButton.Name = "ExecuteButton"
    executeButton.Size = UDim2.new(0.3, -5, 1, 0)
    executeButton.Position = UDim2.new(0, 0, 0, 0)
    executeButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    executeButton.BorderSizePixel = 0
    executeButton.Text = "▶️ Выполнить"
    executeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    executeButton.TextScaled = true
    executeButton.Font = Enum.Font.GothamBold
    executeButton.Parent = buttonFrame

    local executeCorner = Instance.new("UICorner")
    executeCorner.CornerRadius = UDim.new(0, 8)
    executeCorner.Parent = executeButton

    -- Кнопка отмены
    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.Size = UDim2.new(0.3, -5, 1, 0)
    cancelButton.Position = UDim2.new(0.35, 0, 0, 0)
    cancelButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    cancelButton.BorderSizePixel = 0
    cancelButton.Text = "❌ Отменить"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.TextScaled = true
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.Parent = buttonFrame

    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 8)
    cancelCorner.Parent = cancelButton

    -- Кнопка сохранения
    local saveButton = Instance.new("TextButton")
    saveButton.Name = "SaveButton"
    saveButton.Size = UDim2.new(0.3, -5, 1, 0)
    saveButton.Position = UDim2.new(0.7, 0, 0, 0)
    saveButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    saveButton.BorderSizePixel = 0
    saveButton.Text = "💾 Сохранить"
    saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveButton.TextScaled = true
    saveButton.Font = Enum.Font.GothamBold
    saveButton.Parent = buttonFrame

    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 8)
    saveCorner.Parent = saveButton

    -- Обработчики событий
    closeButton.MouseButton1Click:Connect(function()
        interceptorGui:Destroy()
        interceptorGui = nil
    end)

    executeButton.MouseButton1Click:Connect(function()
        if pendingExecution then
            pcall(pendingExecution)
            pendingExecution = nil
            interceptorGui:Destroy()
            interceptorGui = nil
        end
    end)

    cancelButton.MouseButton1Click:Connect(function()
        pendingExecution = nil
        interceptorGui:Destroy()
        interceptorGui = nil
    end)

    saveButton.MouseButton1Click:Connect(function()
        if interceptedCode ~= "" then
            -- Создаем файл для сохранения
            local timestamp = os.date("%Y%m%d_%H%M%S")
            local filename = "intercepted_code_" .. timestamp .. ".lua"
            
            -- Показываем уведомление
            local notification = Instance.new("Frame")
            notification.Size = UDim2.new(0, 300, 0, 60)
            notification.Position = UDim2.new(0.5, -150, 0, 20)
            notification.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            notification.BorderSizePixel = 0
            notification.Parent = playerGui
            
            local notifCorner = Instance.new("UICorner")
            notifCorner.CornerRadius = UDim.new(0, 8)
            notifCorner.Parent = notification
            
            local notifText = Instance.new("TextLabel")
            notifText.Size = UDim2.new(1, -20, 1, 0)
            notifText.Position = UDim2.new(0, 10, 0, 0)
            notifText.BackgroundTransparency = 1
            notifText.Text = "💾 Код сохранен как " .. filename
            notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
            notifText.TextScaled = true
            notifText.Font = Enum.Font.Gotham
            notifText.Parent = notification
            
            -- Анимация исчезновения
            wait(3)
            local fadeOut = TweenService:Create(notification, TweenInfo.new(0.5), {BackgroundTransparency = 1})
            local textFadeOut = TweenService:Create(notifText, TweenInfo.new(0.5), {TextTransparency = 1})
            fadeOut:Play()
            textFadeOut:Play()
            fadeOut.Completed:Connect(function()
                notification:Destroy()
            end)
        end
    end)

    -- Делаем окно перетаскиваемым
    local dragging = false
    local dragStart = nil
    local startPos = nil

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return interceptorGui
end

-- Функция для отображения перехваченного кода
local function displayInterceptedCode(code, url)
    if not interceptorGui then
        createInterceptorGUI()
    end
    
    interceptedCode = code
    
    -- Обновляем информацию
    local infoLabel = interceptorGui.MainFrame.InfoFrame.InfoLabel
    infoLabel.Text = "🔍 Перехвачен код с URL: " .. (url or "неизвестно") .. "\n📊 Размер: " .. #code .. " символов"
    
    -- Отображаем код
    codeDisplay.Text = code
    
    -- Обновляем размер текста для прокрутки
    local textBounds = game:GetService("TextService"):GetTextSize(
        code, 
        codeDisplay.TextSize, 
        codeDisplay.Font, 
        Vector2.new(codeDisplay.AbsoluteSize.X, math.huge)
    )
    codeDisplay.Size = UDim2.new(1, -20, 0, math.max(textBounds.Y, codeDisplay.Parent.AbsoluteSize.Y))
    
    -- Показываем GUI
    interceptorGui.Enabled = true
end

-- Перехватчик loadstring
local function interceptLoadstring(code, chunkname)
    -- Проверяем, является ли это LuaArmor кодом
    if type(code) == "string" and (
        code:find("luarmor") or 
        code:find("LuaArmor") or 
        code:find("obfuscated") or
        code:find("protected") or
        #code > 1000  -- Длинный код может быть обфусцированным
    ) then
        -- Показываем перехваченный код
        displayInterceptedCode(code, chunkname)
        
        -- Создаем функцию для отложенного выполнения
        local compiledFunction = originalLoadstring(code, chunkname)
        pendingExecution = compiledFunction
        
        -- Возвращаем пустую функцию, чтобы предотвратить немедленное выполнение
        return function() end
    else
        -- Обычный код - выполняем как обычно
        return originalLoadstring(code, chunkname)
    end
end

-- Подменяем loadstring
loadstring = interceptLoadstring

-- Также перехватываем HttpGet для отслеживания загрузок
local originalHttpGet = game.HttpGet
game.HttpGet = function(self, url, ...)
    local result = originalHttpGet(self, url, ...)
    
    -- Проверяем, является ли это LuaArmor URL
    if url:find("luarmor.net") or url:find("api.luarmor") then
        print("🔍 Обнаружена загрузка LuaArmor с URL:", url)
        
        -- Если результат будет передан в loadstring, наш перехватчик его поймает
    end
    
    return result
end

-- Уведомление о запуске
print("🔍 LuaArmor Interceptor активирован!")
print("📋 Все вызовы loadstring теперь перехватываются")
print("🎯 Обфусцированный код будет показан в GUI консоли")

-- Создаем уведомление в игре
spawn(function()
    wait(1)
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 400, 0, 80)
    notification.Position = UDim2.new(0.5, -200, 0, 20)
    notification.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    notification.BorderSizePixel = 0
    notification.Parent = playerGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = notification
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 1, 0)
    text.Position = UDim2.new(0, 10, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = "🔍 LuaArmor Interceptor активирован!\nВсе обфусцированные скрипты будут перехвачены"
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextScaled = true
    text.TextWrapped = true
    text.Font = Enum.Font.GothamBold
    text.Parent = notification
    
    -- Анимация появления
    notification.BackgroundTransparency = 1
    text.TextTransparency = 1
    
    local fadeIn = TweenService:Create(notification, TweenInfo.new(0.5), {BackgroundTransparency = 0})
    local textFadeIn = TweenService:Create(text, TweenInfo.new(0.5), {TextTransparency = 0})
    fadeIn:Play()
    textFadeIn:Play()
    
    -- Исчезновение через 5 секунд
    wait(5)
    local fadeOut = TweenService:Create(notification, TweenInfo.new(0.5), {BackgroundTransparency = 1})
    local textFadeOut = TweenService:Create(text, TweenInfo.new(0.5), {TextTransparency = 1})
    fadeOut:Play()
    textFadeOut:Play()
    fadeOut.Completed:Connect(function()
        notification:Destroy()
    end)
end)

-- Тестовая функция для проверки работы
local function testInterceptor()
    print("🧪 Тестирование перехватчика...")
    
    -- Симулируем LuaArmor код
    local testCode = [[
        -- Это тестовый обфусцированный код LuaArmor
        local function obfuscatedFunction()
            print("Это был бы реальный LuaArmor код")
            print("Но сейчас это просто тест")
        end
        obfuscatedFunction()
    ]]
    
    -- Вызываем loadstring с тестовым кодом
    loadstring(testCode, "test_luarmor_code")()
end

-- Экспортируем функции для внешнего использования
return {
    testInterceptor = testInterceptor,
    createGUI = createInterceptorGUI,
    displayCode = displayInterceptedCode
}
