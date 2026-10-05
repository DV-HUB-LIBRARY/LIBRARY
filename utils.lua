local TweenService = game:GetService("TweenService")

local Utils = {}

function Utils.corner(instance, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = instance
    return c
end

function Utils.stroke(instance, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(42, 42, 53)
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = instance
    return s
end

function Utils.padding(instance, all)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, all)
    p.PaddingBottom = UDim.new(0, all)
    p.PaddingLeft = UDim.new(0, all)
    p.PaddingRight = UDim.new(0, all)
    p.Parent = instance
    return p
end

function Utils.tween(instance, props, duration)
    local t = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

function Utils.hover(btn, normalColor, hoverColor)
    btn.MouseEnter:Connect(function()
        Utils.tween(btn, { BackgroundColor3 = hoverColor })
    end)
    btn.MouseLeave:Connect(function()
        Utils.tween(btn, { BackgroundColor3 = normalColor })
    end)
end

function Utils.clearChildren(parent, types)
    for _, child in ipairs(parent:GetChildren()) do
        if not types or table.find(types, child.ClassName) then
            child:Destroy()
        end
    end
end

function Utils.formatTime(timestamp)
    return os.date("%H:%M", tonumber(timestamp) or os.time())
end

function Utils.formatDate(timestamp)
    return os.date("%d/%m/%y", tonumber(timestamp) or os.time())
end

function Utils.escape(str)
    return tostring(str):gsub("[%c]", "")
end

return Utils
