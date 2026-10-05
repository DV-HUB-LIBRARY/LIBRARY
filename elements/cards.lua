local Card = {}

function Card.new(parent, options, Config, Utils)
    options = options or {}
    
    local card = Instance.new("Frame")
    card.Name = options.Name or "Card"
    card.Size = options.Size or UDim2.new(1, -20, 0, 60)
    card.Position = options.Position or UDim2.new(0, 10, 0, 10)
    card.BackgroundColor3 = options.BackgroundColor or Config.Colors.Card
    card.BorderSizePixel = 0
    card.ZIndex = options.ZIndex or 13
    card.Parent = parent
    
    Utils.corner(card, options.Radius or Config.Sizes.Radius)
    Utils.stroke(card, options.StrokeColor or Config.Colors.Border, 1)
    
    local padding = Utils.padding(card, options.Padding or Config.Sizes.Padding)
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, Config.Sizes.GapSmall)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = card
    
    card.AutomaticSize = Enum.AutomaticSize.Y
    
    return card
end

return Card
