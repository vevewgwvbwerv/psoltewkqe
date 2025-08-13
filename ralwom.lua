-- Создаём GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextBox = Instance.new("TextBox")
local TextLabel = Instance.new("TextLabel")
local ScrollFrame = Instance.new("ScrollingFrame")
local CodeLabel = Instance.new("TextLabel")
local ExecuteButton = Instance.new("TextButton")
local CopyButton = Instance.new("TextButton")

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
ExecuteButton.Size = UDim2.new(0.5, -15, 0, 30)
ExecuteButton.Position = UDim2.new(0, 10, 0, 70)
ExecuteButton.Text = "Перехватить код"
ExecuteButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteButton.Font = Enum.Font.SourceSansBold
ExecuteButton.TextSize = 16
ExecuteButton.Parent = Frame

-- Кнопка копирования
CopyButton.Size = UDim2.new(0.5, -15, 0, 30)
CopyButton.Position = UDim2.new(0.5, 5, 0, 70)
CopyButton.Text = "Копировать"
CopyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.Font = Enum.Font.SourceSansBold
CopyButton.TextSize = 16
CopyButton.Parent = Frame

-- Поле для отображения кода
ScrollFrame.Size = UDim2.new(1, -20, 1, -110)
ScrollFrame.Position = UDim2.new(0, 10, 0, 110)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.XY
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Parent = Frame

CodeLabel.Size = UDim2.new(0, 0, 0, 0)
CodeLabel.Text = ""
CodeLabel.TextXAlignment = Enum.TextXAlignment.Left
CodeLabel.TextYAlignment = Enum.TextYAlignment.Top
CodeLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
CodeLabel.BackgroundTransparency = 1
CodeLabel.TextWrapped = false
CodeLabel.TextSize = 14
CodeLabel.Font = Enum.Font.Code
CodeLabel.Parent = ScrollFrame

-- Утилиты
local function UpdateCanvasSize()
    local text = CodeLabel.Text or ""
    local bounds = TextService:GetTextSize(text, CodeLabel.TextSize, CodeLabel.Font, Vector2.new(100000, 100000))
    local padX, padY = 10, 10
    local width = math.max(bounds.X + padX, ScrollFrame.AbsoluteSize.X)
    local height = math.max(bounds.Y + padY, ScrollFrame.AbsoluteSize.Y)
    CodeLabel.Size = UDim2.new(0, width, 0, height)
    ScrollFrame.CanvasSize = UDim2.new(0, width, 0, height)
end

local function notify(msg)
    local prev = TextLabel.Text
    TextLabel.Text = msg
    task.delay(1.5, function()
        -- Возвращаем исходный текст, если пользователь не изменил его вручную
        if TextLabel and TextLabel.Parent then
            TextLabel.Text = prev
        end
    end)
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
            CodeLabel.Text = data
            UpdateCanvasSize()
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

-- Пересчитываем размеры при изменении текста (на всякий случай)
CodeLabel:GetPropertyChangedSignal("Text"):Connect(UpdateCanvasSize)
