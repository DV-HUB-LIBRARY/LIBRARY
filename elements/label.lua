local Label = {}

function Label.new(parent, options, Config, Utils)
    options = options or {}
    
    local label = Instance.new("TextLabel")
    label.Name = options.Name or "Label"
    label.Size = options.Size or UDim2.new(1, 0, 0, 18)
    label.Position = options.Position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = options.BackgroundTransparency or 1
    label.Font = options.Font or Config.Fonts.Body
    label.Text = options.Text or ""
    label.TextColor3 = options.TextColor or Config.Colors.Text
    label.TextSize = options.TextSize or Config.Sizes.BodySize
    label.TextXAlignment = options.TextXAlignment or Enum.TextXAlignment.Left
    label.TextYAlignment = options.TextYAlignment or Enum.TextYAlignment.Center
    label.TextWrapped = options.TextWrapped or false
    label.ZIndex = options.ZIndex or 15
    label.Parent = parent
    
    function label:UpdateText(text)
        self.Text = tostring(text)
    end
    
    function label:UpdateColor(color)
        self.TextColor3 = color
    end
    
    return label
end

return Label
