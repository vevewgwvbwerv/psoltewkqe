-- Создаём GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextBox = Instance.new("TextBox")
local TextLabel = Instance.new("TextLabel")
local ScrollFrame = Instance.new("ScrollingFrame")
local CodeLabel = Instance.new("TextLabel")
local ExecuteButton = Instance.new("TextButton")
local CopyButton = Instance.new("TextButton")
local CacheButton = Instance.new("TextButton")
local SaveButton = Instance.new("TextButton")
local HookButton = Instance.new("TextButton")

local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

-- Подключаем GUI к CoreGui
ScreenGui.Parent = game.CoreGui

-- Настройки главного окна
Frame.Size = UDim2.new(0, 600, 0, 400)
Frame.Position = UDim2.new(0.5, -300, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Текстовое описание
TextLabel.Text = "Вставь команду с loadstring:"
TextLabel.Size = UDim2.new(1, 0, 0, 30)
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1
TextLabel.Font = Enum.Font.SourceSansBold
TextLabel.TextSize = 18
TextLabel.Parent = Frame

-- Поле для ввода команды
TextBox.Size = UDim2.new(1, -20, 0, 30)
TextBox.Position = UDim2.new(0, 10, 0, 35)
TextBox.Text = ""
TextBox.PlaceholderText = 'Пример: loadstring(game:HttpGet("https://example.com/script.lua"))()'
TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
TextBox.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
TextBox.ClearTextOnFocus = false
TextBox.Parent = Frame

-- Кнопка запуска
ExecuteButton.Size = UDim2.new(0.25, -7.5, 0, 30)
ExecuteButton.Position = UDim2.new(0, 10, 0, 70)
ExecuteButton.Text = "Перехватить код"
ExecuteButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteButton.Font = Enum.Font.SourceSansBold
ExecuteButton.TextSize = 16
ExecuteButton.Parent = Frame

-- Кнопка копирования
CopyButton.Size = UDim2.new(0.25, -7.5, 0, 30)
CopyButton.Position = UDim2.new(0.25, 2.5, 0, 70)
CopyButton.Text = "Копировать"
CopyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.Font = Enum.Font.SourceSansBold
CopyButton.TextSize = 16
CopyButton.Parent = Frame

-- Кнопка кеша
CacheButton.Size = UDim2.new(0.25, -7.5, 0, 30)
CacheButton.Position = UDim2.new(0.5, 2.5, 0, 70)
CacheButton.Text = "Из кеша"
CacheButton.BackgroundColor3 = Color3.fromRGB(80, 40, 80)
CacheButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CacheButton.Font = Enum.Font.SourceSansBold
CacheButton.TextSize = 16
CacheButton.Parent = Frame

-- Кнопка сохранения
SaveButton.Size = UDim2.new(0.25, -7.5, 0, 30)
SaveButton.Position = UDim2.new(0.75, 2.5, 0, 70)
SaveButton.Text = "Сохранить"
SaveButton.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveButton.Font = Enum.Font.SourceSansBold
SaveButton.TextSize = 16
SaveButton.Parent = Frame

-- Кнопка Memory Hook
HookButton.Size = UDim2.new(1, -20, 0, 30)
HookButton.Position = UDim2.new(0, 10, 0, 105)
HookButton.Text = "🔓 Установить Memory Hook (перехват кода)"
HookButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
HookButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HookButton.Font = Enum.Font.SourceSansBold
HookButton.TextSize = 16
HookButton.Parent = Frame

-- Поле для отображения кода
ScrollFrame.Size = UDim2.new(1, -20, 1, -145)
ScrollFrame.Position = UDim2.new(0, 10, 0, 145)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.XY
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Parent = Frame

CodeLabel.Size = UDim2.new(0, 0, 0, 0)
CodeLabel.Text = ""
CodeLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
CodeLabel.BackgroundTransparency = 1
CodeLabel.TextWrapped = false
CodeLabel.TextSize = 14
CodeLabel.Font = Enum.Font.Code
CodeLabel.Parent = ScrollFrame

-- Утилиты
local function UpdateCanvasSize()
    local text = CodeLabel.Text or ""
    if #text == 0 then
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        return
    end
    
    local size = TextService:GetTextSize(text, CodeLabel.TextSize, CodeLabel.Font, Vector2.new(ScrollFrame.AbsoluteSize.X, math.huge))
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, size.Y)
    CodeLabel.Size = UDim2.new(1, 0, 0, size.Y)
    CodeLabel.Position = UDim2.new(0, 0, 0, 0)
end

local function truncateText(text, maxLength)
    if #text <= maxLength then
        return text
    end
    
    return text:sub(1, maxLength) .. "\n\n[ТЕКСТ ОБРЕЗАН - СЛИШКОМ ДЛИННЫЙ: " .. #text .. " символов]\n[Используйте кнопку 'Сохранить' для полного текста]"
end

local function notify(message)
    print("[LUAFINDER] " .. message)
    
    -- Анимация уведомления
    if TextLabel then
        local originalColor = TextLabel.TextColor3
        TextLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        TextLabel.Text = message
        
        TweenService:Create(TextLabel, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextColor3 = originalColor
        }):Play()
        
        wait(2)
        TextLabel.Text = "Вставь команду с loadstring:"
    end
end

local function tryReadCache()
    local cachePaths = {
        "static_content_130525/initv4.lua",
        "static_content_130525/init.lua", 
        "static_content_130525/initv2.lua",
        "static_content_130525/initv3.lua"
    }
    
    for _, path in ipairs(cachePaths) do
        local success, content = pcall(function()
            if readfile and isfile and isfile(path) then
                return readfile(path)
            end
            return nil
        end)
        if success and content and #content > 100 then
            return content, path
        end
    end
    return nil, nil
end

-- Расширенный Memory Hook для деобфускации
local hookInstalled = false
local interceptedCode = ""
local deobfuscatedCode = ""

-- Функция для проверки, является ли строка обфусцированным кодом
local function isObfuscatedCode(str)
    if not str or type(str) ~= "string" then return false end
    
    -- Проверяем на наличие признаков обфускации
    local obfuscationPatterns = {
        "getfenv", "setfenv", "loadstring", "string%.char", 
        "string%.sub", "string%.gsub", "math%.random", 
        "%[%d+%][%s]*=[%s]*[0-9A-Fa-f]+"
    }
    
    local score = 0
    for _, pattern in ipairs(obfuscationPatterns) do
        local count = 0
        for _ in str:gmatch(pattern) do
            count = count + 1
        end
        if count > 0 then
            score = score + count
        end
    end
    
    -- Если найдено много признаков обфускации
    return score > 3
end

-- Функция для попытки деобфускации кода
local function attemptDeobfuscation(code)
    if not code or #code == 0 then return code end
    
    -- Простая замена часто используемых обфускационных паттернов
    local deobfuscated = code
    
    -- Заменяем string.char(...) вызовы с числовыми аргументами
    deobfuscated = deobfuscated:gsub("string%.char%(([%d%s,]+)%)", function(args)
        local bytes = {}
        for num in args:gmatch("%d+") do
            table.insert(bytes, string.char(tonumber(num)))
        end
        return '"' .. table.concat(bytes) .. '"'
    end)
    
    -- Заменяем getfenv()[...] вызовы
    deobfuscated = deobfuscated:gsub("getfenv%(%)(%b[])", function(index)
        return "_G" .. index
    end)
    
    return deobfuscated
end

-- Попытка сохранения файла
local function trySaveFile(content)
    if not writefile then
        return false, "writefile не поддерживается"
    end
    
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local filename = "luafinder_deobfuscated_" .. timestamp .. ".lua"
    
    local success, err = pcall(function()
        writefile(filename, content)
    end)
    
    if success then
        return true, filename
    else
        return false, err
    end
end

local function tryCopy(text)
    local attempts = {
        function(t)
            if setclipboard then setclipboard(t) return true end
            return false
        end,
        function(t)
            if toclipboard then toclipboard(t) return true end
            return false
        end,
        function(t)
            if syn and syn.write_clipboard then syn.write_clipboard(t) return true end
            return false
        end,
        function(t)
            if setrbxclipboard then setrbxclipboard(t) return true end
            return false
        end,
    }
    for _, fn in ipairs(attempts) do
        local ok = false
        local success, err = pcall(function()
            ok = fn(text)
        end)
        if success and ok then return true end
    end
    return false
end

-- Улучшенная функция установки Memory Hook
local function installMemoryHook()
    if hookInstalled then
        notify("Hook уже установлен!")
        return
    end
    
    notify("Установка расширенных Memory Hook для LuArmor V4...")
    
    -- Перехватываем loadstring
    local original_loadstring = loadstring
    local hookCount = 0
    
    getgenv().loadstring = function(code, chunkName)
        hookCount = hookCount + 1
        
        if code and type(code) == "string" then
            print("\n[LUAFINDER] === ПЕРЕХВАТЧИК LOADSTRING #" .. hookCount .. " ===")
            print("[LUAFINDER] Размер кода: " .. #code .. " символов")
            
            -- Если код большой, это может быть обфусцированный скрипт
            if #code > 1000 then
                print("[LUAFINDER] Обнаружен большой кодовой блок (возможно обфусцированный)")
                
                -- Сохраняем оригинальный код
                interceptedCode = code
                
                -- Пытаемся выполнить базовую деобфускацию
                local deobfCode = attemptDeobfuscation(code)
                
                if deobfCode ~= code then
                    print("[LUAFINDER] Применена базовая деобфускация")
                    deobfuscatedCode = deobfCode
                else
                    deobfuscatedCode = code
                end
                
                -- Выводим полный код в консоль
                print("[LUAFINDER] === НАЧАЛО ПЕРЕХВАЧЕННОГО КОДА ===")
                print(deobfuscatedCode)
                print("[LUAFINDER] === КОНЕЦ ПЕРЕХВАЧЕННОГО КОДА ===\n")
                
                -- Отображаем в GUI
                CodeLabel.Text = truncateText(deobfuscatedCode, 50000)
                UpdateCanvasSize()
                
                -- Автоматически сохраняем код в файл
                local success, result = trySaveFile(deobfuscatedCode)
                if success then
                    print("[LUAFINDER] Код автоматически сохранен в: " .. result)
                    notify("Код перехвачен и сохранен в " .. result)
                else
                    print("[LUAFINDER] Ошибка автосохранения: " .. tostring(result))
                    notify("Код перехвачен, но ошибка сохранения: " .. tostring(result))
                end
                
                return original_loadstring(deobfCode, chunkName)
            else
                print("[LUAFINDER] Маленький кодовой блок: " .. code)
            end
        end
        
        -- Вызываем оригинальную функцию
        return original_loadstring(code, chunkName)
    end
    
    -- Перехватываем pcall для отслеживания выполнения функций
    local original_pcall = pcall
    getgenv().pcall = function(func, ...)
        if type(func) == "function" then
            -- Пытаемся получить информацию о функции
            local info = debug.getinfo(func)
            if info and info.source and info.source:find("loadstring") then
                print("[LUAFINDER] PCALL: Вызов функции из loadstring")
            end
        end
        return original_pcall(func, ...)
    end
    
    -- Перехватываем string.char для обнаружения расшифровки
    if string and string.char then
        local original_string_char = string.char
        string.char = function(...)
            local result = original_string_char(...)
            
            -- Если результат похож на код
            if result and #result > 50 and isObfuscatedCode(result) then
                print("\n[LUAFINDER] === STRING.CHAR РАСШИФРОВКА ОБНАРУЖЕНА ===")
                print("[LUAFINDER] Расшифрованный код (" .. #result .. " символов):")
                print(result)
                print("[LUAFINDER] === КОНЕЦ РАСШИФРОВАННОГО КОДА ===\n")
                
                -- Сохраняем расшифрованный код
                interceptedCode = result
                deobfuscatedCode = result
                
                -- Отображаем в GUI
                CodeLabel.Text = truncateText(result, 50000)
                UpdateCanvasSize()
                
                -- Автоматически сохраняем код в файл
                local success, filename = trySaveFile(result)
                if success then
                    print("[LUAFINDER] Расшифрованный код сохранен в: " .. filename)
                    notify("Расшифрованный код сохранен в " .. filename)
                end
            end
            
            return result
        end
    end
    
    -- Перехватываем string.dump для получения байткода
    if string.dump then
        local original_string_dump = string.dump
        string.dump = function(func, strip)
            print("[LUAFINDER] STRING.DUMP вызван для функции")
            
            -- Получаем информацию о функции
            local info = debug.getinfo(func)
            if info then
                print("[LUAFINDER] Информация о функции:")
                print("  Имя: " .. (info.name or "анонимная"))
                print("  Источник: " .. (info.source or "неизвестен"))
                print("  Линия определения: " .. (info.linedefined or 0))
            end
            
            -- Получаем байткод
            local bytecode = original_string_dump(func, strip)
            print("[LUAFINDER] Размер байткода: " .. #bytecode .. " байт")
            
            return bytecode
        end
    end
    
    hookInstalled = true
    notify("✅ Расширенные Memory Hook успешно установлены!")
    notify("Теперь запустите защищенный скрипт для перехвата и деобфускации кода.")
end

-- Логика кнопки
ExecuteButton.MouseButton1Click:Connect(function()
    local input = TextBox.Text
    -- Извлекаем http/https URL до пробела, кавычки или закрывающей скобки
    local url = input:match("https?://[^%)%s'\"]+")
    if url then
        local success, data = pcall(function()
            return game:HttpGet(url)
        end)
        if success then
            local displayText = truncateText(data, 50000) -- Лимит 50k символов для отображения
            CodeLabel.Text = displayText
            UpdateCanvasSize()
            if #data > 50000 then
                notify("Текст обрезан (" .. #data .. " симв.). Используйте 'Сохранить'.")
            end
        else
            CodeLabel.Text = "Ошибка запроса: " .. tostring(data)
        end
    else
        CodeLabel.Text = "Не удалось найти ссылку в команде!"
    end
end)

CopyButton.MouseButton1Click:Connect(function()
    if CodeLabel.Text and #CodeLabel.Text > 0 then
        local ok = tryCopy(CodeLabel.Text)
        if ok then
            notify("Скопировано в буфер обмена.")
        else
            notify("Не удалось скопировать: среда не поддерживает.")
        end
    else
        notify("Нечего копировать: поле пустое.")
    end
end)

CacheButton.MouseButton1Click:Connect(function()
    local content, path = tryReadCache()
    if content then
        local displayText = truncateText(content, 50000)
        CodeLabel.Text = displayText
        UpdateCanvasSize()
        if #content > 50000 then
            notify("Кеш загружен (" .. #content .. " симв.) из " .. path)
        else
            notify("Кеш загружен из " .. path)
        end
        
        -- Пытаемся выполнить деобфускацию
        local deobfCode = attemptDeobfuscation(content)
        if deobfCode ~= content then
            print("[LUAFINDER] === ДЕОБФУСЦИРОВАННЫЙ КОД ИЗ КЕША ===")
            print(deobfCode)
            print("[LUAFINDER] === КОНЕЦ ДЕОБФУСЦИРОВАННОГО КОДА ===\n")
            
            -- Обновляем отображение в GUI
            CodeLabel.Text = truncateText(deobfCode, 50000)
            UpdateCanvasSize()
            
            -- Сохраняем в файл
            local success, filename = trySaveFile(deobfCode)
            if success then
                print("[LUAFINDER] Деобфусцированный код из кеша сохранен в: " .. filename)
                notify("Деобфусцированный код из кеша сохранен в " .. filename)
            end
        end
    else
        CodeLabel.Text = "Кеш не найден. Попробуйте сначала запустить загрузчик."
        notify("Файлы кеша не найдены.")
    end
end)

SaveButton.MouseButton1Click:Connect(function()
    if CodeLabel.Text and #CodeLabel.Text > 0 then
        -- Пытаемся получить полный текст (не обрезанный)
        local fullText = CodeLabel.Text
        
        -- Если текст был обрезан, пытаемся получить полный из кеша или последнего запроса
        if fullText:find("ТЕКСТ ОБРЕЗАН") then
            local content, _ = tryReadCache()
            if content then
                fullText = content
            end
        end
        
        local success, result = trySaveFile(fullText)
        if success then
            notify("Сохранено в " .. result)
        else
            notify("Ошибка сохранения: " .. result)
        end
    else
        notify("Нечего сохранять: поле пустое.")
    end
end)

HookButton.MouseButton1Click:Connect(function()
    if type(installMemoryHook) == "function" then
        installMemoryHook()
    else
        notify("Ошибка: installMemoryHook не определена!")
    end
end)

-- Пересчитываем размеры при изменении текста (на всякий случай)
CodeLabel:GetPropertyChangedSignal("Text"):Connect(UpdateCanvasSize)

-- Автоматическая установка Memory Hook при запуске
notify("LUAFINDER запущен. Установка Memory Hook для перехвата LuArmor V4...")
wait(1) -- Небольшая задержка перед установкой хуков
if type(installMemoryHook) == "function" then
    installMemoryHook()
else
    notify("Ошибка: installMemoryHook не определена при автозапуске!")
end
