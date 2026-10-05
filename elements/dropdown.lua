local Dropdown = {}

function Dropdown.new(parent, options, Config, Utils)
    options = options or {}
    
    local container = Instance.new("Frame")
    container.Name = options.Name or "Dropdown"
    container.Size = options.Size or UDim2.new(1, 0, 0, Config.Sizes.RowH)
    container.Position = options.Position or UDim2.new(0, 0, 0, 0)
    container.BackgroundColor3 = Config.Colors.Card
    container.BorderSizePixel = 0
    container.ClipsDescendants = false
    container.ZIndex = options.ZIndex or 14
    container.Parent = parent
    
    Utils.corner(container, Config.Sizes.RadiusSmall)
    Utils.stroke(container, Config.Colors.Border, 1)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -140, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Config.Fonts.Body
    label.Text = options.Text or "Select"
    label.TextColor3 = Config.Colors.Text
    label.TextSize = Config.Sizes.BodySize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 15
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 100, 1, 0)
    valueLabel.Position = UDim2.new(1, -126, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Config.Fonts.Body
    valueLabel.Text = tostring(options.Default or "...")
    valueLabel.TextColor3 = Config.Colors.Muted
    valueLabel.TextSize = Config.Sizes.BodySize
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 15
    valueLabel.Parent = container
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -26, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Font = Config.Fonts.Title
    arrow.Text = "v"
    arrow.TextColor3 = Config.Colors.Muted
    arrow.TextSize = 12
    arrow.ZIndex = 15
    arrow.Parent = container
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 16
    button.Parent = container
    
    local list = Instance.new("Frame")
    list.Size = UDim2.new(1, 0, 0, 0)
    list.Position = UDim2.new(0, 0, 1, 4)
    list.BackgroundColor3 = Config.Colors.Base
    list.BorderSizePixel = 0
    list.Visible = false
    list.ZIndex = 100
    list.Parent = container
    Utils.corner(list, Config.Sizes.RadiusSmall)
    Utils.stroke(list, Config.Colors.Border, 1)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = list
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 4)
    listPadding.PaddingBottom = UDim.new(0, 4)
    listPadding.PaddingLeft = UDim.new(0, 4)
    listPadding.PaddingRight = UDim.new(0, 4)
    listPadding.Parent = list
    
    list.AutomaticSize = Enum.AutomaticSize.Y
    
    local values = options.Values or {}
    local currentValue = options.Default or (values[1] or "")
    local isOpen = false
    
    valueLabel.Text = tostring(currentValue)
    
    local function rebuildList()
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for _, val in ipairs(values) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 26)
            optBtn.BackgroundColor3 = (val == currentValue) and Config.Colors.Accent or Config.Colors.Card
            optBtn.Text = tostring(val)
            optBtn.TextColor3 = Config.Colors.Text
            optBtn.Font = Config.Fonts.Body
            optBtn.TextSize = Config.Sizes.BodySize
            optBtn.BorderSizePixel = 0
            optBtn.AutoButtonColor = false
            optBtn.ZIndex = 101
            optBtn.Parent = list
            Utils.corner(optBtn, Config.Sizes.RadiusSmall)
            
            optBtn.MouseButton1Click:Connect(function()
                currentValue = val
                valueLabel.Text = tostring(val)
                isOpen = false
                list.Visible = false
                arrow.Text = "v"
                rebuildList()
                if options.OnSelect then
                    options.OnSelect(val)
                end
            end)
        end
    end
    
    rebuildList()
    
    button.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        list.Visible = isOpen
        arrow.Text = isOpen and "^" or "v"
    end)
    
    return container
end

return Dropdown
