local Notification = {}

function Notification.send(window, options, Config, Utils)
    options = options or {}
    
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 3
    
    local screenGui = window.ScreenGui
    
    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(0, 260, 0, 60)
    notif.Position = UDim2.new(0.5, -130, 0, -80)
    notif.BackgroundColor3 = Config.Colors.Card
    notif.BorderSizePixel = 0
    notif.ZIndex = 400
    notif.Parent = screenGui
    
    Utils.corner(notif, Config.Sizes.RadiusSmall)
    Utils.stroke(notif, Config.Colors.Accent, 2)
    
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 1, -8)
    accentBar.Position = UDim2.new(0, 4, 0, 4)
    accentBar.BackgroundColor3 = Config.Colors.Accent
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 401
    accentBar.Parent = notif
    Utils.corner(accentBar, 3)
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -20, 0, 20)
    titleLbl.Position = UDim2.new(0, 14, 0, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Config.Fonts.Title
    titleLbl.Text = title
    titleLbl.TextColor3 = Config.Colors.Text
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 401
    titleLbl.Parent = notif
    
    local contentLbl = Instance.new("TextLabel")
    contentLbl.Size = UDim2.new(1, -20, 0, 16)
    contentLbl.Position = UDim2.new(0, 14, 0, 30)
    contentLbl.BackgroundTransparency = 1
    contentLbl.Font = Config.Fonts.Body
    contentLbl.Text = content
    contentLbl.TextColor3 = Config.Colors.Muted
    contentLbl.TextSize = 10
    contentLbl.TextXAlignment = Enum.TextXAlignment.Left
    contentLbl.ZIndex = 401
    contentLbl.Parent = notif
    
    local targetY = 20
    Utils.tween(notif, {
        Position = UDim2.new(0.5, -130, 0, targetY)
    }, 0.25)
    
    task.delay(duration, function()
        if notif and notif.Parent then
            Utils.tween(notif, {
                Position = UDim2.new(0.5, -130, 0, -80)
            }, 0.25)
            task.wait(0.3)
            notif:Destroy()
        end
    end)
    
    return notif
end

return Notification
