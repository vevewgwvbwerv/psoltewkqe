-- TW2LOCK Premium GUI Script for Roblox
-- Modern high-quality interface

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TW2LOCK_Premium_GUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Remove screen darkening

-- Main container with modern design (adjusted size)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainContainer"
mainFrame.Size = UDim2.new(0, 340, 0, 210)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -105)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Modern rounded corners
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

-- Gradient border
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

-- Header with gradient
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

-- Header text with effects
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

-- Glowing effect for header
local titleGlow = titleLabel:Clone()
titleGlow.Name = "TitleGlow"
titleGlow.Position = UDim2.new(0, 22, 0, 2)
titleGlow.TextColor3 = Color3.fromRGB(100, 200, 255)
titleGlow.TextTransparency = 0.7
titleGlow.ZIndex = titleLabel.ZIndex - 1
titleGlow.Parent = headerFrame

-- Function to create premium toggle
local function createPremiumToggle(name, displayText, yPosition, initialState)
    -- Row container with modern design
    local rowFrame = Instance.new("Frame")
    rowFrame.Name = name .. "Row"
    rowFrame.Size = UDim2.new(1, -40, 0, 60)
    rowFrame.Position = UDim2.new(0, 20, 0, yPosition)
    rowFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    rowFrame.BorderSizePixel = 0
    rowFrame.Parent = mainFrame
    
    -- Rounded corners for row
    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 12)
    rowCorner.Parent = rowFrame
    
    -- Neon glowing border
    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = initialState and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(60, 60, 80)
    rowStroke.Thickness = 2
    rowStroke.Transparency = initialState and 0.3 or 0.7
    rowStroke.Parent = rowFrame
    
    -- Neon gradient for row border
    local rowStrokeGradient = Instance.new("UIGradient")
    rowStrokeGradient.Color = initialState and ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 100, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 150))
    } or ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 80))
    }
    rowStrokeGradient.Rotation = 45
    rowStrokeGradient.Parent = rowStroke
    
    -- Gradient background
    local rowGradient = Instance.new("UIGradient")
    rowGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 45))
    }
    rowGradient.Rotation = 90
    rowGradient.Parent = rowFrame
    
    -- Toggle text with modern font
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
    
    -- Glowing effect for text
    local labelGlow = toggleLabel:Clone()
    labelGlow.Name = "LabelGlow"
    labelGlow.Position = UDim2.new(0, 22, 0, 2)
    labelGlow.TextColor3 = initialState and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(100, 100, 150)
    labelGlow.TextTransparency = 0.8
    labelGlow.ZIndex = toggleLabel.ZIndex - 1
    labelGlow.Parent = rowFrame
    
    -- Perfect iOS-style toggle with neon colors
    local toggleTrack = Instance.new("Frame")
    toggleTrack.Name = "ToggleTrack"
    toggleTrack.Size = UDim2.new(0, 70, 0, 35)
    toggleTrack.Position = UDim2.new(1, -90, 0.5, -17.5)
    toggleTrack.BackgroundColor3 = initialState and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(80, 80, 100)
    toggleTrack.BorderSizePixel = 0
    toggleTrack.Parent = rowFrame
    
    -- Rounded corners for track
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0.5, 0)
    trackCorner.Parent = toggleTrack
    
    -- Neon track border
    local trackStroke = Instance.new("UIStroke")
    trackStroke.Color = initialState and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(60, 60, 80)
    trackStroke.Thickness = 2
    trackStroke.Transparency = initialState and 0.3 or 0.8
    trackStroke.Parent = toggleTrack
    
    -- Neon gradient for track (like GUI border)
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
    
    -- Gradient for track border
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
    
    -- Slider (button)
    local slider = Instance.new("Frame")
    slider.Name = "Slider"
    slider.Size = UDim2.new(0, 29, 0, 29)
    slider.Position = initialState and UDim2.new(1, -32, 0.5, -14.5) or UDim2.new(0, 3, 0.5, -14.5)
    slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    slider.BorderSizePixel = 0
    slider.Parent = toggleTrack
    
    -- Rounded slider
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0.5, 0)
    sliderCorner.Parent = slider
    
    -- Slider shadow
    local sliderStroke = Instance.new("UIStroke")
    sliderStroke.Color = Color3.fromRGB(0, 0, 0)
    sliderStroke.Thickness = 1
    sliderStroke.Transparency = 0.9
    sliderStroke.Parent = slider
    
    -- Slider gradient
    local sliderGradient = Instance.new("UIGradient")
    sliderGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 240, 240))
    }
    sliderGradient.Rotation = 90
    sliderGradient.Parent = slider
    
    -- Toggle state
    local isToggled = initialState
    
    -- Toggle function with amazing animations
    local function toggle()
        isToggled = not isToggled
        
        -- Slider animation
        local sliderTween = TweenService:Create(slider, 
            TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
            {Position = isToggled and UDim2.new(1, -32, 0.5, -14.5) or UDim2.new(0, 3, 0.5, -14.5)}
        )
        
        -- Track animation with neon colors
        local trackColorTween = TweenService:Create(toggleTrack,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = isToggled and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(80, 80, 100)}
        )
        
        -- Track border animation
        local strokeColorTween = TweenService:Create(trackStroke,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                Color = isToggled and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(60, 60, 80),
                Transparency = isToggled and 0.3 or 0.8
            }
        )
        
        -- Instant gradient switching (gradient animation not possible)
        trackGradient.Color = isToggled and ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 100, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 150))
        } or ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 100, 120)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 80))
        }
        
        trackStrokeGradient.Color = isToggled and ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 100, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 150))
        } or ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 80)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 80))
        }
        
        -- Text glow animation
        local glowTween = TweenService:Create(labelGlow,
            TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {TextColor3 = isToggled and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(100, 100, 150)}
        )
        
        -- Row border animation with neon colors
        local strokeTween = TweenService:Create(rowStroke,
            TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {
                Color = isToggled and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(60, 60, 80),
                Transparency = isToggled and 0.3 or 0.7
            }
        )
        
        -- Instant row border gradient switching
        rowStrokeGradient.Color = isToggled and ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 100, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 150))
        } or ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 80)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 80))
        }
        
        -- Premium ripple wave effect on activation
        if isToggled then
            -- Create ripple wave effect
            local ripple = Instance.new("Frame")
            ripple.Name = "RippleEffect"
            ripple.Size = UDim2.new(0, 20, 0, 20)
            ripple.Position = UDim2.new(0.5, -10, 0.5, -10)
            ripple.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
            ripple.BackgroundTransparency = 0.3
            ripple.BorderSizePixel = 0
            ripple.ZIndex = rowFrame.ZIndex + 5
            ripple.Parent = rowFrame
            
            local rippleCorner = Instance.new("UICorner")
            rippleCorner.CornerRadius = UDim.new(0.5, 0)
            rippleCorner.Parent = ripple
            
            local rippleStroke = Instance.new("UIStroke")
            rippleStroke.Color = Color3.fromRGB(150, 100, 255)
            rippleStroke.Thickness = 2
            rippleStroke.Transparency = 0.2
            rippleStroke.Parent = ripple
            
            -- Ripple expansion animation
            local rippleExpand = TweenService:Create(ripple,
                TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {
                    Size = UDim2.new(1.5, 0, 2, 0),
                    Position = UDim2.new(-0.25, 0, -0.5, 0),
                    BackgroundTransparency = 1
                }
            )
            
            local rippleStrokeExpand = TweenService:Create(rippleStroke,
                TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Transparency = 1}
            )
            
            rippleExpand:Play()
            rippleStrokeExpand:Play()
            
            rippleExpand.Completed:Connect(function()
                ripple:Destroy()
            end)
            
            -- Premium particle burst effect
            for i = 1, 8 do
                local particle = Instance.new("Frame")
                particle.Name = "Particle" .. i
                particle.Size = UDim2.new(0, 4, 0, 4)
                particle.Position = UDim2.new(0.5, -2, 0.5, -2)
                particle.BackgroundColor3 = Color3.fromRGB(255, 100 + i * 15, 150)
                particle.BackgroundTransparency = 0.2
                particle.BorderSizePixel = 0
                particle.ZIndex = rowFrame.ZIndex + 6
                particle.Parent = rowFrame
                
                local particleCorner = Instance.new("UICorner")
                particleCorner.CornerRadius = UDim.new(0.5, 0)
                particleCorner.Parent = particle
                
                -- Random direction for each particle
                local angle = (i - 1) * (360 / 8) + math.random(-15, 15)
                local radians = math.rad(angle)
                local distance = math.random(40, 80)
                local endX = math.cos(radians) * distance
                local endY = math.sin(radians) * distance
                
                -- Particle explosion animation
                local particleMove = TweenService:Create(particle,
                    TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {
                        Position = UDim2.new(0.5, endX - 2, 0.5, endY - 2),
                        Size = UDim2.new(0, 2, 0, 2),
                        BackgroundTransparency = 1
                    }
                )
                
                -- Delayed start for staggered effect
                wait(0.02)
                particleMove:Play()
                
                particleMove.Completed:Connect(function()
                    particle:Destroy()
                end)
            end
            
            -- Premium flash effect
            local flash = Instance.new("Frame")
            flash.Name = "FlashEffect"
            flash.Size = UDim2.new(1, 0, 1, 0)
            flash.Position = UDim2.new(0, 0, 0, 0)
            flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            flash.BackgroundTransparency = 0.7
            flash.BorderSizePixel = 0
            flash.ZIndex = rowFrame.ZIndex + 7
            flash.Parent = rowFrame
            
            local flashCorner = Instance.new("UICorner")
            flashCorner.CornerRadius = UDim.new(0, 12)
            flashCorner.Parent = flash
            
            -- Flash fade animation
            local flashFade = TweenService:Create(flash,
                TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundTransparency = 1}
            )
            
            flashFade:Play()
            flashFade.Completed:Connect(function()
                flash:Destroy()
            end)
        end
        
        -- Pulse effect on toggle
        local pulseScale = TweenService:Create(slider,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 33, 0, 33)}
        )
        
        local pulseBack = TweenService:Create(slider,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 29, 0, 29)}
        )
        
        -- Start all animations
        sliderTween:Play()
        trackColorTween:Play()
        strokeColorTween:Play()
        glowTween:Play()
        strokeTween:Play()
        pulseScale:Play()
        
        pulseScale.Completed:Connect(function()
            pulseBack:Play()
        end)
        
        -- Console output
        print(displayText .. ": " .. (isToggled and "ENABLED" or "DISABLED"))
        
        return isToggled
    end
    
    -- Click handler
    local clickDetector = Instance.new("TextButton")
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ""
    clickDetector.Parent = rowFrame
    
    clickDetector.MouseButton1Click:Connect(function()
        toggle()
    end)
    
    -- Hover effects
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

-- Create premium toggles (initially disabled)
local freezeTradeToggle = createPremiumToggle("FreezeTrade", "FREEZE TRADE", 65, false)
local autoAcceptToggle = createPremiumToggle("AutoAccept", "AUTO ACCEPT", 135, false)

-- Make interface draggable with smooth effects
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
        
        -- Press effect
        local pressEffect = TweenService:Create(headerFrame,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(55, 55, 70)}
        )
        pressEffect:Play()
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                -- Return to normal color
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

-- Amazing GUI appearance animation
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundTransparency = 1

-- Main container appearance animation
local sizeAppear = TweenService:Create(mainFrame,
    TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Size = UDim2.new(0, 340, 0, 210)}
)

local fadeAppear = TweenService:Create(mainFrame,
    TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {BackgroundTransparency = 0}
)

-- Gradient border animation
local borderRotation = TweenService:Create(borderGradient,
    TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
    {Rotation = 405}
)

-- Start animations
sizeAppear:Play()
fadeAppear:Play()
wait(0.5)
borderRotation:Play()

-- Header pulse animation
local function pulseTitle()
    local pulseTween = TweenService:Create(titleGlow,
        TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {TextTransparency = 0.4}
    )
    pulseTween:Play()
end

pulseTitle()

print("🚀 TW2LOCK Premium GUI successfully loaded! 🚀")
