-- Простой LuaArmor перехватчик для Roblox
-- Скопируйте этот код и вставьте в Roblox Studio или эксплойт

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Сохраняем оригинальные функции
local originalLoadstring = loadstring
local originalHttpGet = game.HttpGet

-- Переменные
local interceptorGui = nil
local interceptedCode = ""
local pendingFunction = nil

-- Создание простого GUI
local function createGUI()
    if interceptorGui then interceptorGui:Destroy() end
    
    interceptorGui = Instance.new("ScreenGui")
    interceptorGui.Name = "CodeInterceptor"
    interceptorGui.ResetOnSpawn = false
    interceptorGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0.8, 0)
    frame.Position = UDim2.new(0.1, 0, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 100, 100)
    frame.Parent = interceptorGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    title.BorderSizePixel = 0
    title.Text = "🔍 ПЕРЕХВАЧЕН LUARMOR КОД"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -100)
    scrollFrame.Position = UDim2.new(0, 5, 0, 45)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    scrollFrame.BorderSizePixel = 1
    scrollFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.ScrollBarThickness = 10
    scrollFrame.Parent = frame

    local codeLabel = Instance.new("TextLabel")
    codeLabel.Size = UDim2.new(1, -20, 1, 0)
    codeLabel.Position = UDim2.new(0, 10, 0, 0)
    codeLabel.BackgroundTransparency = 1
    codeLabel.Text = interceptedCode
    codeLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    codeLabel.TextSize = 14
    codeLabel.TextXAlignment = Enum.TextXAlignment.Left
    codeLabel.TextYAlignment = Enum.TextYAlignment.Top
    codeLabel.TextWrapped = true
    codeLabel.Font = Enum.Font.Code
    codeLabel.Parent = scrollFrame

    -- Обновляем размер для прокрутки
    local textService = game:GetService("TextService")
    local textSize = textService:GetTextSize(
        interceptedCode,
        14,
        Enum.Font.Code,
        Vector2.new(scrollFrame.AbsoluteSize.X - 20, math.huge)
    )
    codeLabel.Size = UDim2.new(1, -20, 0, math.max(textSize.Y, scrollFrame.AbsoluteSize.Y))
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textSize.Y + 20)

    -- Кнопки
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 50)
    buttonFrame.Position = UDim2.new(0, 0, 1, -50)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Parent = frame

    local executeBtn = Instance.new("TextButton")
    executeBtn.Size = UDim2.new(0.25, -5, 0.8, 0)
    executeBtn.Position = UDim2.new(0, 5, 0.1, 0)
    executeBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    executeBtn.BorderSizePixel = 0
    executeBtn.Text = "▶️ ВЫПОЛНИТЬ"
    executeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    executeBtn.TextScaled = true
    executeBtn.Font = Enum.Font.SourceSansBold
    executeBtn.Parent = buttonFrame

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0.25, -5, 0.8, 0)
    cancelBtn.Position = UDim2.new(0.25, 5, 0.1, 0)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    cancelBtn.BorderSizePixel = 0
    cancelBtn.Text = "❌ ОТМЕНИТЬ"
    cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelBtn.TextScaled = true
    cancelBtn.Font = Enum.Font.SourceSansBold
    cancelBtn.Parent = buttonFrame

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0.25, -5, 0.8, 0)
    copyBtn.Position = UDim2.new(0.5, 5, 0.1, 0)
    copyBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    copyBtn.BorderSizePixel = 0
    copyBtn.Text = "📋 КОПИРОВАТЬ"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.TextScaled = true
    copyBtn.Font = Enum.Font.SourceSansBold
    copyBtn.Parent = buttonFrame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.25, -5, 0.8, 0)
    closeBtn.Position = UDim2.new(0.75, 5, 0.1, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕ ЗАКРЫТЬ"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = buttonFrame

    -- События кнопок
    executeBtn.MouseButton1Click:Connect(function()
        if pendingFunction then
            local success, error = pcall(pendingFunction)
            if not success then
                print("❌ Ошибка выполнения:", error)
            else
                print("✅ Код выполнен успешно")
            end
        end
        interceptorGui:Destroy()
    end)

    cancelBtn.MouseButton1Click:Connect(function()
        print("❌ Выполнение отменено")
        interceptorGui:Destroy()
    end)

    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(interceptedCode)
            print("📋 Код скопирован в буфер обмена")
        else
            print("📋 Функция копирования недоступна")
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        interceptorGui:Destroy()
    end)
end

-- Перехватчик loadstring
loadstring = function(code, chunkname)
    if type(code) == "string" and (
        code:find("luarmor") or 
        code:find("LuaArmor") or
        #code > 2000 or
        code:find("getfenv") or
        code:find("setfenv")
    ) then
        print("🔍 ПЕРЕХВАЧЕН LUARMOR КОД!")
        print("📊 Размер:", #code, "символов")
        
        interceptedCode = code
        pendingFunction = originalLoadstring(code, chunkname)
        
        createGUI()
        
        -- Возвращаем пустую функцию
        return function() end
    else
        return originalLoadstring(code, chunkname)
    end
end

-- Перехватчик HttpGet
game.HttpGet = function(self, url, ...)
    local result = originalHttpGet(self, url, ...)
    
    if url:find("luarmor") then
        print("🌐 Загрузка с LuaArmor:", url)
        print("📊 Размер ответа:", #result, "символов")
        
        -- Сразу показываем код
        interceptedCode = result
        pendingFunction = originalLoadstring(result, url)
        createGUI()
    end
    
    return result
end

-- Уведомление о запуске
print("🔍 LuaArmor Interceptor активирован!")
print("📋 Теперь все LuaArmor скрипты будут перехвачены")

-- Создаем визуальное уведомление
local notif = Instance.new("ScreenGui")
notif.Name = "InterceptorNotification"
notif.Parent = playerGui

local notifFrame = Instance.new("Frame")
notifFrame.Size = UDim2.new(0, 400, 0, 80)
notifFrame.Position = UDim2.new(0.5, -200, 0, 50)
notifFrame.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
notifFrame.BorderSizePixel = 2
notifFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
notifFrame.Parent = notif

local notifText = Instance.new("TextLabel")
notifText.Size = UDim2.new(1, -20, 1, 0)
notifText.Position = UDim2.new(0, 10, 0, 0)
notifText.BackgroundTransparency = 1
notifText.Text = "🔍 LuaArmor Interceptor АКТИВИРОВАН!\nВсе обфусцированные скрипты будут перехвачены"
notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
notifText.TextScaled = true
notifText.TextWrapped = true
notifText.Font = Enum.Font.SourceSansBold
notifText.Parent = notifFrame

-- Удаляем уведомление через 5 секунд
game:GetService("Debris"):AddItem(notif, 5)

print("✅ Готов к перехвату! Запустите ваш LuaArmor скрипт.")
