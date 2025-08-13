-- Interactive LuaArmor Interceptor
-- Self-contained script with GUI for manual input and code interception

-- Check if we're in a Roblox environment
if not game then
    print("[ERROR] This script must be run in a Roblox environment")
    return
end

-- Store original functions
local original_loadstring = loadstring
local original_pcall = pcall
local original_xpcall = xpcall
local original_HttpGet = game.HttpGet

-- Table to store intercepted code
local interceptedCode = {}
local executionHistory = {}

-- Function to safely add intercepted code
local function addInterceptedCode(source, chunkname, method)
    table.insert(interceptedCode, {
        source = source,
        chunkname = chunkname,
        method = method or "unknown",
        timestamp = tick()
    })
    
    -- Print to console for immediate viewing
    print("[INTERCEPTED] Code intercepted via " .. method .. ":")
    print(source)
    print("----------------------------------------")
end

-- Enhanced loadstring hook
loadstring = function(source, chunkname)
    addInterceptedCode(source, chunkname, "loadstring")
    -- Return a dummy function instead of the actual loaded function
    return function() 
        print("[EXECUTION] Dummy function executed (code was intercepted)")
    end
end

-- Enhanced HttpGet hook
if game.HttpGet then
    game.HttpGet = function(self, url, nocache)
        local result = original_HttpGet(self, url, nocache)
        print("[INTERCEPTED] HttpGet request to: " .. tostring(url))
        addInterceptedCode(result, url, "HttpGet")
        return result
    end
end

-- Enhanced pcall and xpcall hooks
pcall = function(func, ...)
    if type(func) == "function" then
        table.insert(executionHistory, {
            func = func,
            args = {...},
            timestamp = tick(),
            method = "pcall"
        })
    end
    return original_pcall(func, ...)
end

xpcall = function(func, errHandler, ...)
    if type(func) == "function" then
        table.insert(executionHistory, {
            func = func,
            args = {...},
            timestamp = tick(),
            method = "xpcall"
        })
    end
    return original_xpcall(func, errHandler, ...)
end

-- Function to safely execute user input
local function safeExecute(input)
    local success, result = pcall(function()
        -- Add to execution history
        table.insert(executionHistory, {
            input = input,
            timestamp = tick(),
            method = "user_input"
        })
        
        -- Execute the input
        return loadstring(input)()
    end)
    
    if not success then
        warn("[ERROR] Failed to execute input: " .. tostring(result))
        return false, result
    end
    
    return true, result
end

-- Function to execute LuaArmor script
local function executeLuaArmorScript(url)
    local success, result = pcall(function()
        -- Add to execution history
        table.insert(executionHistory, {
            url = url,
            timestamp = tick(),
            method = "luarmor_script"
        })
        
        -- Execute the LuaArmor script
        return loadstring(game:HttpGet(url))()
    end)
    
    if not success then
        warn("[ERROR] Failed to execute LuaArmor script: " .. tostring(result))
        return false, result
    end
    
    return true, result
end

-- Interactive GUI Console
local function createInteractiveGUI()
    -- Prevent multiple GUI instances
    if game.Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("LuaArmorInterceptor") then
        return
    end
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LuaArmorInterceptor"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0.9, 0, 0.9, 0)
    mainFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.new(0, 0.5, 1)
    mainFrame.Parent = screenGui
    
    -- Create Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.05, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Interactive LuaArmor Interceptor"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame
    
    -- Create Input Section
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -20, 0.2, 0)
    inputFrame.Position = UDim2.new(0, 10, 0.05, 10)
    inputFrame.BackgroundTransparency = 0.8
    inputFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    inputFrame.Parent = mainFrame
    
    local inputLabel = Instance.new("TextLabel")
    inputLabel.Size = UDim2.new(1, 0, 0.2, 0)
    inputLabel.Position = UDim2.new(0, 0, 0, 0)
    inputLabel.BackgroundTransparency = 1
    inputLabel.Text = "Enter Lua code or LuaArmor URL:"
    inputLabel.TextColor3 = Color3.new(1, 1, 1)
    inputLabel.TextScaled = true
    inputLabel.Font = Enum.Font.SourceSans
    inputLabel.Parent = inputFrame
    
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, 0, 0.6, 0)
    inputBox.Position = UDim2.new(0, 0, 0.2, 0)
    inputBox.BackgroundTransparency = 0.7
    inputBox.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    inputBox.TextColor3 = Color3.new(1, 1, 1)
    inputBox.Text = "loadstring(game:HttpGet(\"https://api.luarmor.net/files/v4/loaders/0e08efc5390446f12bb3f48e59cc6766.lua\"))()"
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.TextYAlignment = Enum.TextYAlignment.Top
    inputBox.Font = Enum.Font.Monospace
    inputBox.TextSize = 14
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = inputFrame
    
    -- Create Buttons
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0.2, 0)
    buttonFrame.Position = UDim2.new(0, 0, 0.8, 0)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = inputFrame
    
    local executeButton = Instance.new("TextButton")
    executeButton.Size = UDim2.new(0.3, 0, 1, 0)
    executeButton.Position = UDim2.new(0, 0, 0, 0)
    executeButton.Text = "Execute Code"
    executeButton.TextColor3 = Color3.new(1, 1, 1)
    executeButton.BackgroundColor3 = Color3.new(0.3, 0.6, 0.3)
    executeButton.Parent = buttonFrame
    
    local executeLuaArmorButton = Instance.new("TextButton")
    executeLuaArmorButton.Size = UDim2.new(0.3, 0, 1, 0)
    executeLuaArmorButton.Position = UDim2.new(0.35, 0, 0, 0)
    executeLuaArmorButton.Text = "Execute LuaArmor"
    executeLuaArmorButton.TextColor3 = Color3.new(1, 1, 1)
    executeLuaArmorButton.BackgroundColor3 = Color3.new(0.6, 0.3, 0.3)
    executeLuaArmorButton.Parent = buttonFrame
    
    local clearButton = Instance.new("TextButton")
    clearButton.Size = UDim2.new(0.3, 0, 1, 0)
    clearButton.Position = UDim2.new(0.7, 0, 0, 0)
    clearButton.Text = "Clear Results"
    clearButton.TextColor3 = Color3.new(1, 1, 1)
    clearButton.BackgroundColor3 = Color3.new(0.6, 0.6, 0.3)
    clearButton.Parent = buttonFrame
    
    -- Create Tabs
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, 0, 0.05, 0)
    tabFrame.Position = UDim2.new(0, 0, 0.25, 10)
    tabFrame.BackgroundTransparency = 0.8
    tabFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    tabFrame.Parent = mainFrame
    
    local tabIntercepted = Instance.new("TextButton")
    tabIntercepted.Size = UDim2.new(0.33, 0, 1, 0)
    tabIntercepted.Position = UDim2.new(0, 0, 0, 0)
    tabIntercepted.Text = "Intercepted Code"
    tabIntercepted.TextColor3 = Color3.new(1, 1, 1)
    tabIntercepted.BackgroundTransparency = 0.5
    tabIntercepted.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    tabIntercepted.Parent = tabFrame
    
    local tabExecution = Instance.new("TextButton")
    tabExecution.Size = UDim2.new(0.33, 0, 1, 0)
    tabExecution.Position = UDim2.new(0.33, 0, 0, 0)
    tabExecution.Text = "Execution History"
    tabExecution.TextColor3 = Color3.new(1, 1, 1)
    tabExecution.BackgroundTransparency = 0.5
    tabExecution.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    tabExecution.Parent = tabFrame
    
    local tabInfo = Instance.new("TextButton")
    tabInfo.Size = UDim2.new(0.34, 0, 1, 0)
    tabInfo.Position = UDim2.new(0.66, 0, 0, 0)
    tabInfo.Text = "Info"
    tabInfo.TextColor3 = Color3.new(1, 1, 1)
    tabInfo.BackgroundTransparency = 0.5
    tabInfo.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    tabInfo.Parent = tabFrame
    
    -- Create ScrollingFrame for content display
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 0.65, -40)
    scrollFrame.Position = UDim2.new(0, 10, 0.3, 10)
    scrollFrame.BackgroundTransparency = 0.5
    scrollFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 10
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = mainFrame
    
    -- Create TextLabel for content display
    local contentDisplay = Instance.new("TextLabel")
    contentDisplay.Name = "ContentDisplay"
    contentDisplay.Size = UDim2.new(1, -20, 0, 0)
    contentDisplay.Position = UDim2.new(0, 10, 0, 0)
    contentDisplay.BackgroundTransparency = 1
    contentDisplay.Text = "Intercepted code will appear here...\n\n1. Enter your Lua code or LuaArmor URL in the input box above\n2. Click 'Execute Code' to run general Lua code\n3. Click 'Execute LuaArmor' to run a LuaArmor script\n4. Intercepted code will appear in this panel"
    contentDisplay.TextColor3 = Color3.new(1, 1, 1)
    contentDisplay.TextXAlignment = Enum.TextXAlignment.Left
    contentDisplay.TextYAlignment = Enum.TextYAlignment.Top
    contentDisplay.TextWrapped = true
    contentDisplay.RichText = true
    contentDisplay.Font = Enum.Font.Monospace
    contentDisplay.TextSize = 14
    contentDisplay.Parent = scrollFrame
    
    -- Update function for displaying content
    local currentTab = "intercepted"
    
    local function updateDisplay()
        local text = ""
        
        if currentTab == "intercepted" then
            for i, code in ipairs(interceptedCode) do
                text = text .. "[[ " .. code.method .. " - " .. os.date("%H:%M:%S", math.floor(code.timestamp)) .. " ]]\n" .. code.source .. "\n\n"
            end
            
            if text == "" then
                text = "Intercepted code will appear here...\n\n1. Enter your Lua code or LuaArmor URL in the input box above\n2. Click 'Execute Code' to run general Lua code\n3. Click 'Execute LuaArmor' to run a LuaArmor script\n4. Intercepted code will appear in this panel"
            end
        elseif currentTab == "execution" then
            for i, exec in ipairs(executionHistory) do
                if exec.input then
                    text = text .. "[[ " .. exec.method .. " - " .. os.date("%H:%M:%S", math.floor(exec.timestamp)) .. " ]]\nInput: " .. exec.input .. "\n\n"
                elseif exec.url then
                    text = text .. "[[ " .. exec.method .. " - " .. os.date("%H:%M:%S", math.floor(exec.timestamp)) .. " ]]\nURL: " .. exec.url .. "\n\n"
                else
                    text = text .. "[[ " .. exec.method .. " - " .. os.date("%H:%M:%S", math.floor(exec.timestamp)) .. " ]]\nFunction execution\n\n"
                end
            end
            
            if text == "" then
                text = "Execution history will appear here...\n\nThis tab shows all executed code and scripts."
            end
        else -- info tab
            text = "Interactive LuaArmor Interceptor\n\nFeatures:\n- Execute custom Lua code\n- Execute LuaArmor scripts\n- Intercept loadstring calls\n- Intercept HttpGet requests\n- View intercepted code\n- View execution history\n\nInstructions:\n1. Enter your code or URL in the input box\n2. Click the appropriate execute button\n3. View results in the panels above\n\nNote: This interceptor may not work with all obfuscation methods. Some advanced protection systems may prevent interception."
        end
        
        contentDisplay.Text = text
        
        -- Update canvas size
        contentDisplay.Size = UDim2.new(1, -20, 0, contentDisplay.TextBounds.Y)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentDisplay.TextBounds.Y + 20)
    end
    
    -- Button event handlers
    executeButton.MouseButton1Click:Connect(function()
        local input = inputBox.Text
        if input and input ~= "" then
            local success, result = safeExecute(input)
            if success then
                print("[SUCCESS] Code executed successfully")
            else
                print("[ERROR] Code execution failed: " .. tostring(result))
            end
            updateDisplay()
        end
    end)
    
    executeLuaArmorButton.MouseButton1Click:Connect(function()
        local input = inputBox.Text
        if input and input ~= "" then
            -- Extract URL from loadstring(game:HttpGet("URL"))()
            local url = input:match('HttpGet%("(.-)"%)')
            if url then
                local success, result = executeLuaArmorScript(url)
                if success then
                    print("[SUCCESS] LuaArmor script executed successfully")
                else
                    print("[ERROR] LuaArmor script execution failed: " .. tostring(result))
                end
                updateDisplay()
            else
                print("[ERROR] Could not extract URL from input")
            end
        end
    end)
    
    clearButton.MouseButton1Click:Connect(function()
        interceptedCode = {}
        executionHistory = {}
        updateDisplay()
    end)
    
    -- Tab switching
    tabIntercepted.MouseButton1Click:Connect(function()
        currentTab = "intercepted"
        tabIntercepted.BackgroundTransparency = 0.2
        tabIntercepted.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
        tabExecution.BackgroundTransparency = 0.5
        tabExecution.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        tabInfo.BackgroundTransparency = 0.5
        tabInfo.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        updateDisplay()
    end)
    
    tabExecution.MouseButton1Click:Connect(function()
        currentTab = "execution"
        tabExecution.BackgroundTransparency = 0.2
        tabExecution.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
        tabIntercepted.BackgroundTransparency = 0.5
        tabIntercepted.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        tabInfo.BackgroundTransparency = 0.5
        tabInfo.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        updateDisplay()
    end)
    
    tabInfo.MouseButton1Click:Connect(function()
        currentTab = "info"
        tabInfo.BackgroundTransparency = 0.2
        tabInfo.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
        tabIntercepted.BackgroundTransparency = 0.5
        tabIntercepted.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        tabExecution.BackgroundTransparency = 0.5
        tabExecution.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        updateDisplay()
    end)
    
    -- Update display when new code is intercepted
    local updateConnection
    updateConnection = game:GetService("RunService").Heartbeat:Connect(function()
        -- Update display only when needed to avoid performance issues
    end)
    
    -- Initial update
    updateDisplay()
    
    -- Create Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0.2, 0, 0.05, 0)
    closeButton.Position = UDim2.new(0.8, -10, 0.95, -10)
    closeButton.AnchorPoint = Vector2.new(1, 1)
    closeButton.Text = "Close"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    closeButton.Parent = mainFrame
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if updateConnection then
            updateConnection:Disconnect()
        end
    end)
    
    return screenGui
end

-- Initialize the interceptor
print("[LuaArmor Interceptor] Initializing interactive interceptor...")

-- Create GUI
local success, gui = pcall(createInteractiveGUI)
if not success then
    warn("[LuaArmor Interceptor] Failed to create GUI: " .. tostring(gui))
else
    print("[LuaArmor Interceptor] Interactive GUI created successfully!")
end

print("[LuaArmor Interceptor] Ready! Use the GUI to execute and intercept LuaArmor code.")

return true
