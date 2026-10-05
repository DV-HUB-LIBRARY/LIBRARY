local Input = {}

function Input.new(parent, options, Config, Utils)
    options = options or {}
    
    local container = Instance.new("Frame")
    container.Name = options.Name or "InputContainer"
    container.Size = options.Size or UDim2.new(1, 0, 0, Config.Sizes.InputH + 4)
    container.Position = options.Position or UDim2.new(0, 0, 0, 0)
    container.BackgroundColor3 = options.BackgroundColor or Config.Colors.Base
    container.BorderSizePixel = 0
    container.ZIndex = options.ZIndex or 14
    container.Parent = parent
    
    Utils.corner(container, Config.Sizes.RadiusSmall)
    Utils.stroke(container, Config.Colors.Border, 1)
    
    local textbox = Instance.new("TextBox")
    textbox.Name = "TextBox"
    textbox.Size = UDim2.new(1, -12, 1, 0)
    textbox.Position = UDim2.new(0, 6, 0, 0)
    textbox.BackgroundTransparency = 1
    textbox.Font = options.Font or Config.Fonts.Body
    textbox.Text = options.Default or ""
    textbox.PlaceholderText = options.Placeholder or "Ketik..."
    textbox.PlaceholderColor3 = Config.Colors.Muted
    textbox.TextColor3 = Config.Colors.Text
    textbox.TextSize = options.TextSize or Config.Sizes.BodySize
    textbox.TextXAlignment = Enum.TextXAlignment.Left
    textbox.ClearTextOnFocus = false
    textbox.ZIndex = 15
    textbox.Parent = container
    
    textbox.FocusLost:Connect(function()
        if options.OnSubmit then
            options.OnSubmit(textbox.Text)
        end
    end)
    
    if options.OnChange then
        textbox:GetPropertyChangedSignal("Text"):Connect(function()
            options.OnChange(textbox.Text)
        end)
    end
    
    return textbox
end

return Input
