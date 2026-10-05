local Button = {}

function Button.new(parent, options, Config, Utils)
    options = options or {}
    
    local btn = Instance.new("TextButton")
    btn.Name = options.Name or "Button"
    btn.Size = options.Size or UDim2.new(1, -20, 0, Config.Sizes.ButtonH)
    btn.Position = options.Position or UDim2.new(0, 10, 0, 10)
    btn.BackgroundColor3 = options.Color or Config.Colors.Card
    btn.Text = options.Text or "Button"
    btn.TextColor3 = options.TextColor or Config.Colors.Text
    btn.Font = options.Font or Config.Fonts.Title
    btn.TextSize = options.TextSize or Config.Sizes.BodySize
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = options.ZIndex or 14
    btn.Parent = parent
    
    Utils.corner(btn, options.Radius or Config.Sizes.RadiusSmall)
    Utils.stroke(btn, options.StrokeColor or Config.Colors.Border, 1)
    
    local normalColor = options.Color or Config.Colors.Card
    local hoverColor = options.HoverColor or Config.Colors.CardHover
    local originalSize = options.Size or UDim2.new(1, -20, 0, Config.Sizes.ButtonH)
    
    Utils.hover(btn, normalColor, hoverColor)
    
    btn.MouseButton1Down:Connect(function()
        Utils.tween(btn, {
            Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset - 2, originalSize.Y.Scale, originalSize.Y.Offset - 2)
        }, 0.08)
    end)
    
    btn.MouseButton1Up:Connect(function()
        Utils.tween(btn, { Size = originalSize }, 0.08)
    end)
    
    if options.OnClick then
        btn.MouseButton1Click:Connect(options.OnClick)
    end
    
    function btn:UpdateText(text)
        self.Text = tostring(text)
    end
    
    function btn:UpdateColor(color)
        self.BackgroundColor3 = color
        normalColor = color
    end
    
    function btn:UpdateEnabled(enabled)
        self.Active = enabled
        self.AutoButtonColor = enabled
        if not enabled then
            self.TextColor3 = Config.Colors.Muted
        else
            self.TextColor3 = options.TextColor or Config.Colors.Text
        end
    end
    
    return btn
end

return Button
