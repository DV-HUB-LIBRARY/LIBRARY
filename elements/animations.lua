local Animations = {}

function Animations.NeonVerify(profile, Config, Utils, win, onComplete)
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = game.Players.LocalPlayer
    
    local card = profile.Frame
    if not card then return end
    
    local overlay = Instance.new("Frame", card)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(5, 0, 15)
    overlay.BackgroundTransparency = 0
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 200
    Utils.corner(overlay, Config.Sizes.Radius)
    
    local stroke = Instance.new("UIStroke", overlay)
    stroke.Color = Color3.fromRGB(255, 0, 200)
    stroke.Thickness = 2
    
    local glow = Instance.new("UIStroke", overlay)
    glow.Color = Color3.fromRGB(0, 255, 255)
    glow.Thickness = 5
    glow.Transparency = 0.6
    
    local header = Instance.new("TextLabel", overlay)
    header.Size = UDim2.new(1, 0, 0, 16)
    header.Position = UDim2.new(0, 0, 0, 8)
    header.BackgroundTransparency = 1
    header.Font = Config.Fonts.Black
    header.Text = "▓▒░ DV EXPLOITS ░▒▓"
    header.TextColor3 = Color3.fromRGB(255, 0, 200)
    header.TextSize = 13
    header.ZIndex = 201
    
    local userText = Instance.new("TextLabel", overlay)
    userText.Size = UDim2.new(1, -20, 0, 14)
    userText.Position = UDim2.new(0, 10, 0, 32)
    userText.BackgroundTransparency = 1
    userText.Font = Config.Fonts.Title
    userText.Text = "▶ " .. LocalPlayer.Name
    userText.TextColor3 = Color3.fromRGB(0, 255, 255)
    userText.TextSize = 11
    userText.TextXAlignment = Enum.TextXAlignment.Left
    userText.ZIndex = 201
    
    local statusText = Instance.new("TextLabel", overlay)
    statusText.Size = UDim2.new(1, -20, 0, 14)
    statusText.Position = UDim2.new(0, 10, 0.5, -30)
    statusText.BackgroundTransparency = 1
    statusText.Font = Config.Fonts.Black
    statusText.Text = "▶ VERIFYING..."
    statusText.TextColor3 = Color3.fromRGB(0, 255, 255)
    statusText.TextSize = 11
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.ZIndex = 201
    
    local segments = {}
    local segmentsCount = 15
    local barWidth = 0.9
    local segmentWidth = barWidth / segmentsCount
    
    for i = 1, segmentsCount do
        local seg = Instance.new("Frame", overlay)
        seg.Size = UDim2.new(segmentWidth - 0.01, 0, 0, 18)
        seg.Position = UDim2.new(0.05 + (i - 1) * segmentWidth, 0, 0.5, -5)
        seg.BackgroundColor3 = Color3.fromRGB(30, 0, 40)
        seg.BorderSizePixel = 1
        seg.BorderColor3 = Color3.fromRGB(255, 0, 200)
        seg.ZIndex = 201
        Utils.corner(seg, 2)
        table.insert(segments, seg)
    end
    
    local bottomBar = Instance.new("Frame", overlay)
    bottomBar.Size = UDim2.new(0.9, 0, 0, 4)
    bottomBar.Position = UDim2.new(0.05, 0, 1, -18)
    bottomBar.BackgroundColor3 = Color3.fromRGB(40, 0, 50)
    bottomBar.BorderSizePixel = 0
    bottomBar.ZIndex = 201
    Utils.corner(bottomBar, 2)
    
    local bottomFill = Instance.new("Frame", bottomBar)
    bottomFill.Size = UDim2.new(0, 0, 1, 0)
    bottomFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    bottomFill.BorderSizePixel = 0
    bottomFill.ZIndex = 202
    Utils.corner(bottomFill, 2)
    
    local duration = 5
    local startTime = tick()
    local running = true
    
    task.spawn(function()
        while running and overlay.Parent do
            local progress = math.min((tick() - startTime) / duration, 1)
            local filled = math.floor(progress * #segments)
            
            for i, seg in ipairs(segments) do
                if i <= filled then
                    seg.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(255, 0, 200) or Color3.fromRGB(0, 255, 255)
                else
                    seg.BackgroundColor3 = Color3.fromRGB(30, 0, 40)
                end
            end
            
            bottomFill.Size = UDim2.new(progress, 0, 1, 0)
            
            if progress < 0.3 then
                statusText.Text = "▶ VERIFYING..."
            elseif progress < 0.6 then
                statusText.Text = "▶ CHECKING ROLE..."
            elseif progress < 0.9 then
                statusText.Text = "▶ SYNCING..."
            else
                statusText.Text = "▶ ✓ VERIFIED"
            end
            
            if progress >= 1 then break end
            task.wait(0.016)
        end
        running = false
    end)
    
    task.delay(5.3, function()
        TweenService:Create(overlay, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        for _, child in ipairs(overlay:GetDescendants()) do
            if child:IsA("TextLabel") then
                TweenService:Create(child, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
            elseif child:IsA("Frame") then
                TweenService:Create(child, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            elseif child:IsA("UIStroke") then
                TweenService:Create(child, TweenInfo.new(0.4), {Transparency = 1}):Play()
            end
        end
        task.wait(0.5)
        overlay:Destroy()
        if onComplete then onComplete() end
    end)
end

return Animations
