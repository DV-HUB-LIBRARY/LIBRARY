local Toggle = {}

function Toggle.new(parent, options, Config, Utils)
    options = options or {}
    
    local container = Instance.new("Frame")
    container.Name = options.Name or "Toggle"
    container.Size = options.Size or UDim2.new(1, 0, 0, Config.Sizes.RowH)
    container.Position = options.Position or UDim2.new(0, 0, 0, 0)
    container.BackgroundColor3 = options.BackgroundColor or Config.Colors.Card
    container.BorderSizePixel = 0
    container.ZIndex = options.ZIndex or 14
    container.Parent = parent
    
    Utils.corner(container, Config.Sizes.RadiusSmall)
    Utils.stroke(container, Config.Colors.Border, 1)
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Config.Fonts.Body
    label.Text = options.Text or "Toggle"
    label.TextColor3 = Config.Colors.Text
    label.TextSize = Config.Sizes.BodySize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 15
    label.Parent = container
    
    local switchBg = Instance.new("Frame")
    switchBg.Name = "SwitchBg"
    switchBg.Size = UDim2.new(0, 40, 0, 20)
    switchBg.Position = UDim2.new(1, -52, 0.5, -10)
    switchBg.BackgroundColor3 = Config.Colors.Base
    switchBg.BorderSizePixel = 0
    switchBg.ZIndex = 15
    switchBg.Parent = container
    Utils.corner(switchBg, 10)
    Utils.stroke(switchBg, Config.Colors.Border, 1)
    
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Config.Colors.Muted
    knob.BorderSizePixel = 0
    knob.ZIndex = 16
    knob.Parent = switchBg
    Utils.corner(knob, 8)
    
    local button = Instance.new("TextButton")
    button.Name = "ClickArea"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 17
    button.Parent = container
    
    local value = options.Default or false
    
    local function render()
        if value then
            Utils.tween(switchBg, { BackgroundColor3 = Config.Colors.Accent }, 0.15)
            Utils.tween(knob, {
                Position = UDim2.new(1, -18, 0.5, -8),
                BackgroundColor3 = Config.Colors.Text
            }, 0.15)
        else
            Utils.tween(switchBg, { BackgroundColor3 = Config.Colors.Base }, 0.15)
            Utils.tween(knob, {
                Position = UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Config.Colors.Muted
            }, 0.15)
        end
    end
    
    render()
    
    button.MouseButton1Click:Connect(function()
        value = not value
        render()
        if options.OnChange then
            options.OnChange(value)
        end
    end)
    
    container.UpdateValue = function(self, newVal)
        value = newVal and true or false
        render()
    end
    
    container.FetchValue = function(self)
        return value
    end
    
    return container
end

return Toggle
