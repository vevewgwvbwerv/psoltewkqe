-- ИСПРАВЛЕННЫЙ LuaArmor перехватчик (БЕЗ ОШИБОК)
-- Работает только с loadstring перехватом

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Сохраняем оригинальную функцию loadstring
local originalLoadstring = loadstring

-- Переменные
local interceptorGui = nil
local interceptedCode = ""
local pendingFunction = nil

-- Создание GUI
local function createGUI()
    if interceptorGui then 
        interceptorGui:Destroy() 
    end
    
    interceptorGui = Instance.new("ScreenGui")
    interceptorGui.Name = "LuaArmorInterceptor"
    interceptorGui.ResetOnSpawn = false
    interceptorGui.Parent = playerGui

    -- Главное окно
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0.9, 0, 0.9, 0)
    mainFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 3
    mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    mainFrame.Parent = interceptorGui

    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "🔍 LUARMOR КОД ПЕРЕХВАЧЕН! 🔍"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 24
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame

    -- Информация
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -10, 0, 30)
    infoLabel.Position = UDim2.new(0, 5, 0, 55)
    infoLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    infoLabel.BorderSizePixel = 0
    infoLabel.Text = "📊 Размер кода: " .. #interceptedCode .. " символов | ⚠️ ПРОВЕРЬТЕ ПЕРЕД ВЫПОЛНЕНИЕМ!"
    infoLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    infoLabel.TextSize = 16
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.Parent = mainFrame

    -- Область прокрутки для кода
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -140)
    scrollFrame.Position = UDim2.new(0, 5, 0, 90)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    scrollFrame.BorderSizePixel = 2
    scrollFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.ScrollBarThickness = 15
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
    scrollFrame.Parent = mainFrame

    -- Текст с кодом
    local codeLabel = Instance.new("TextLabel")
    codeLabel.Size = UDim2.new(1, -30, 1, 0)
    codeLabel.Position = UDim2.new(0, 15, 0, 0)
    codeLabel.BackgroundTransparency = 1
    codeLabel.Text = interceptedCode
    codeLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    codeLabel.TextSize = 12
    codeLabel.TextXAlignment = Enum.TextXAlignment.Left
    codeLabel.TextYAlignment = Enum.TextYAlignment.Top
    codeLabel.TextWrapped = true
    codeLabel.Font = Enum.Font.Code
    codeLabel.Parent = scrollFrame

    -- Вычисляем размер текста для прокрутки
    local textService = game:GetService("TextService")
    local textBounds = textService:GetTextSize(
        interceptedCode,
        12,
        Enum.Font.Code,
        Vector2.new(scrollFrame.AbsoluteSize.X - 30, math.huge)
    )
    
    codeLabel.Size = UDim2.new(1, -30, 0, math.max(textBounds.Y + 50, scrollFrame.AbsoluteSize.Y))
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textBounds.Y + 100)

    -- Панель кнопок
    local buttonPanel = Instance.new("Frame")
    buttonPanel.Size = UDim2.new(1, 0, 0, 45)
    buttonPanel.Position = UDim2.new(0, 0, 1, -45)
    buttonPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    buttonPanel.BorderSizePixel = 0
    buttonPanel.Parent = mainFrame

    -- Кнопка ВЫПОЛНИТЬ
    local executeBtn = Instance.new("TextButton")
    executeBtn.Size = UDim2.new(0.2, -5, 0.8, 0)
    executeBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
    executeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    executeBtn.BorderSizePixel = 2
    executeBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    executeBtn.Text = "▶️ ВЫПОЛНИТЬ"
    executeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    executeBtn.TextSize = 14
    executeBtn.Font = Enum.Font.SourceSansBold
    executeBtn.Parent = buttonPanel

    -- Кнопка ОТМЕНИТЬ
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0.2, -5, 0.8, 0)
    cancelBtn.Position = UDim2.new(0.275, 0, 0.1, 0)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    cancelBtn.BorderSizePixel = 2
    cancelBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    cancelBtn.Text = "❌ ОТМЕНИТЬ"
    cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelBtn.TextSize = 14
    cancelBtn.Font = Enum.Font.SourceSansBold
    cancelBtn.Parent = buttonPanel

    -- Кнопка СОХРАНИТЬ
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.2, -5, 0.8, 0)
    saveBtn.Position = UDim2.new(0.5, 0, 0.1, 0)
    saveBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    saveBtn.BorderSizePixel = 2
    saveBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.Text = "💾 СОХРАНИТЬ"
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.TextSize = 14
    saveBtn.Font = Enum.Font.SourceSansBold
    saveBtn.Parent = buttonPanel

    -- Кнопка ЗАКРЫТЬ
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.15, -5, 0.8, 0)
    closeBtn.Position = UDim2.new(0.8, 0, 0.1, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    closeBtn.BorderSizePixel = 2
    closeBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "✕ ЗАКРЫТЬ"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = buttonPanel

    -- События кнопок
    executeBtn.MouseButton1Click:Connect(function()
        if pendingFunction then
            print("🚀 Выполняю перехваченный код...")
            local success, result = pcall(pendingFunction)
            if success then
                print("✅ Код выполнен успешно!")
            else
                print("❌ Ошибка при выполнении:", result)
            end
        end
        interceptorGui:Destroy()
    end)

    cancelBtn.MouseButton1Click:Connect(function()
        print("❌ Выполнение LuaArmor кода отменено")
        interceptorGui:Destroy()
    end)

    saveBtn.MouseButton1Click:Connect(function()
        print("💾 Код сохранен в консоль (скопируйте из вывода)")
        print("--- НАЧАЛО LUARMOR КОДА ---")
        print(interceptedCode)
        print("--- КОНЕЦ LUARMOR КОДА ---")
        
        -- Попытка скопировать в буфер обмена (если доступно)
        if setclipboard then
            setclipboard(interceptedCode)
            print("📋 Код также скопирован в буфер обмена")
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        interceptorGui:Destroy()
    end)
end

-- ГЛАВНАЯ ФУНКЦИЯ: Перехватчик loadstring
loadstring = function(source, chunkname)
    -- Проверяем признаки LuaArmor/обфускации
    if type(source) == "string" then
        local isLuaArmor = false
        local codeSize = #source
        
        -- Детекция LuaArmor по различным признакам
        if codeSize > 1500 then isLuaArmor = true end
        if source:find("luarmor") then isLuaArmor = true end
        if source:find("LuaArmor") then isLuaArmor = true end
        if source:find("obfuscated") then isLuaArmor = true end
        if source:find("protected") then isLuaArmor = true end
        if source:find("getfenv") and source:find("setfenv") then isLuaArmor = true end
        if source:find("string%.char") and source:find("string%.byte") then isLuaArmor = true end
        
        -- Если обнаружен LuaArmor код
        if isLuaArmor then
            print("🎯 ОБНАРУЖЕН LUARMOR КОД!")
            print("📊 Размер:", codeSize, "символов")
            print("📝 Chunk name:", chunkname or "неизвестно")
            
            -- Сохраняем код и создаем функцию
            interceptedCode = source
            pendingFunction = originalLoadstring(source, chunkname)
            
            -- Показываем GUI
            createGUI()
            
            -- Возвращаем пустую функцию (код не выполнится автоматически)
            return function() 
                print("⚠️ LuaArmor код заблокирован. Используйте GUI для выполнения.")
            end
        end
    end
    
    -- Обычный код - выполняем как обычно
    return originalLoadstring(source, chunkname)
end

-- Уведомления
print("🔍 === LUARMOR INTERCEPTOR АКТИВИРОВАН ===")
print("📋 Все вызовы loadstring теперь перехватываются")
print("🎯 Обфусцированный код будет показан в GUI")
print("⚠️ Код НЕ будет выполнен автоматически!")
print("✅ Готов к работе!")

-- Визуальное уведомление в игре
spawn(function()
    wait(0.5)
    
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "InterceptorNotification"
    notificationGui.Parent = playerGui
    
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 500, 0, 100)
    notifFrame.Position = UDim2.new(0.5, -250, 0, 50)
    notifFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    notifFrame.BorderSizePixel = 3
    notifFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    notifFrame.Parent = notificationGui
    
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -20, 1, 0)
    notifText.Position = UDim2.new(0, 10, 0, 0)
    notifText.BackgroundTransparency = 1
    notifText.Text = "🔍 LUARMOR INTERCEPTOR АКТИВИРОВАН!\n✅ Готов перехватывать обфусцированные скрипты"
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifText.TextSize = 18
    notifText.TextWrapped = true
    notifText.Font = Enum.Font.SourceSansBold
    notifText.Parent = notifFrame
    
    -- Удаляем через 4 секунды
    game:GetService("Debris"):AddItem(notificationGui, 4)
end)

print("🚀 Теперь запустите ваш LuaArmor скрипт!")
