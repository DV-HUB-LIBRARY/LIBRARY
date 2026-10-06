local KeyManagerWindow = {}

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game.Players.LocalPlayer

local function makeDraggable(handle, target)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function makeModalBase(gui, Config, Utils, titleText, width, height)
    local overlay = Instance.new("Frame", gui)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 900
    
    local modal = Instance.new("Frame", overlay)
    modal.Size = UDim2.new(0, width, 0, height)
    modal.Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2)
    modal.BackgroundColor3 = Config.Colors.Card
    modal.BorderSizePixel = 0
    modal.ZIndex = 901
    modal.ClipsDescendants = true
    Utils.corner(modal, Config.Sizes.Radius)
    Utils.stroke(modal, Config.Colors.Accent, 1)
    
    local header = Instance.new("Frame", modal)
    header.Size = UDim2.new(1, 0, 0, 32)
    header.BackgroundColor3 = Config.Colors.Topbar
    header.BorderSizePixel = 0
    header.ZIndex = 902
    Utils.corner(header, Config.Sizes.Radius)
    
    local mTitle = Instance.new("TextLabel", header)
    mTitle.Size = UDim2.new(1, -60, 1, 0)
    mTitle.Position = UDim2.new(0, 12, 0, 0)
    mTitle.BackgroundTransparency = 1
    mTitle.Font = Config.Fonts.Title
    mTitle.Text = titleText
    mTitle.TextColor3 = Config.Colors.Accent
    mTitle.TextSize = 12
    mTitle.TextXAlignment = Enum.TextXAlignment.Left
    mTitle.ZIndex = 903
    
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
    closeBtn.BackgroundColor3 = Config.Colors.Danger
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Config.Colors.Text
    closeBtn.Font = Config.Fonts.Title
    closeBtn.TextSize = 11
    closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 904
    Utils.corner(closeBtn, 5)
    closeBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
    
    makeDraggable(header, modal)
    makeDraggable(mTitle, modal)
    
    return overlay, modal, closeBtn
end

local function makeScrollContent(modal, Config, topOffset, bottomOffset)
    local scroll = Instance.new("ScrollingFrame", modal)
    scroll.Size = UDim2.new(1, -20, 1, -(topOffset + bottomOffset))
    scroll.Position = UDim2.new(0, 10, 0, topOffset)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Config.Colors.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ZIndex = 902
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local padding = Instance.new("UIPadding", scroll)
    padding.PaddingTop = UDim.new(0, 4)
    padding.PaddingBottom = UDim.new(0, 4)
    padding.PaddingRight = UDim.new(0, 4)
    
    return scroll
end

local function makeInputRow(parent, Config, Utils, label, placeholder, default)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundColor3 = Config.Colors.Base
    row.BorderSizePixel = 0
    row.ZIndex = 903
    Utils.corner(row, Config.Sizes.RadiusSmall)
    Utils.stroke(row, Config.Colors.Border, 1)
    
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0, 90, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Config.Fonts.Body
    lbl.Text = label
    lbl.TextColor3 = Config.Colors.Muted
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 904
    
    local input = Instance.new("TextBox", row)
    input.Size = UDim2.new(1, -106, 1, 0)
    input.Position = UDim2.new(0, 98, 0, 0)
    input.BackgroundTransparency = 1
    input.Font = Config.Fonts.Mono
    input.Text = tostring(default or "")
    input.PlaceholderText = placeholder or ""
    input.PlaceholderColor3 = Config.Colors.Muted
    input.TextColor3 = Config.Colors.Text
    input.TextSize = 11
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.ClearTextOnFocus = false
    input.ZIndex = 904
    
    return input, row
end

local function makeButtonRow(modal, Config, Utils)
    local btnRow = Instance.new("Frame", modal)
    btnRow.Size = UDim2.new(1, -20, 0, 34)
    btnRow.Position = UDim2.new(0, 10, 1, -44)
    btnRow.BackgroundTransparency = 1
    btnRow.ZIndex = 910
    
    local btnLayout = Instance.new("UIListLayout", btnRow)
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.Padding = UDim.new(0, 8)
    
    return btnRow
end

local function makeButton(parent, Config, Utils, text, color, layoutOrder)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.5, -4, 1, 0)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Config.Colors.Text
    btn.Font = Config.Fonts.Title
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.LayoutOrder = layoutOrder or 0
    btn.ZIndex = 911
    Utils.corner(btn, Config.Sizes.RadiusSmall)
    return btn
end

function KeyManagerWindow.showGenerateModalInternal(parentGui, Config, Utils, modules, notify, refreshCallback)
    local gui = parentGui
    
    local overlay, modal = makeModalBase(gui, Config, Utils, "GENERATE KEY", 340, 460)
    local scroll = makeScrollContent(modal, Config, 40, 56)
    
    local tierInput = makeInputRow(scroll, Config, Utils, "Tier:", "user / vip / admin", "vip")
    tierInput.Parent.LayoutOrder = 1
    
    local usageInput = makeInputRow(scroll, Config, Utils, "Max Usage:", "1 / 5 / 10", "1")
    usageInput.Parent.LayoutOrder = 2
    
    local noteInput = makeInputRow(scroll, Config, Utils, "Note:", "opsional", "")
    noteInput.Parent.LayoutOrder = 3
    
    local durationLabel = Instance.new("TextLabel", scroll)
    durationLabel.Size = UDim2.new(1, 0, 0, 16)
    durationLabel.BackgroundTransparency = 1
    durationLabel.Font = Config.Fonts.Title
    durationLabel.Text = "Duration:"
    durationLabel.TextColor3 = Config.Colors.Text
    durationLabel.TextSize = 10
    durationLabel.TextXAlignment = Enum.TextXAlignment.Left
    durationLabel.ZIndex = 903
    durationLabel.LayoutOrder = 4
    
    local durationPicker = modules.DurationPicker.new(scroll, {}, Config, Utils, nil)
    durationPicker.LayoutOrder = 5
    
    local btnRow = makeButtonRow(modal, Config, Utils)
    
    local genBtn = makeButton(btnRow, Config, Utils, "🔑 CREATE KEY", Config.Colors.Accent, 1)
    local cancelBtn = makeButton(btnRow, Config, Utils, "❌ BATAL", Config.Colors.Card, 2)
    
    cancelBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
    
    genBtn.MouseButton1Click:Connect(function()
        local durData = durationPicker.GetValue()
        local tier = tierInput.Text ~= "" and tierInput.Text or "user"
        local maxUsage = tonumber(usageInput.Text) or 1
        local note = noteInput.Text
        
        local body = {
            tier = tier,
            maxUsage = maxUsage,
            note = note,
            count = 1,
        }
        
        if durData.unit == "lifetime" then
            body.amount = 0
            body.unit = "lifetime"
        else
            body.amount = durData.amount
            body.unit = durData.unit
        end
        
        local opts = {
            Url = "https://igr-backen.vercel.app/api/key/generate",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["X-User-Id"] = tostring(LocalPlayer.UserId),
            },
            Body = HttpService:JSONEncode(body),
        }
        
        genBtn.Text = "⏳ LOADING..."
        genBtn.BackgroundColor3 = Config.Colors.Muted
        
        local ok, res = pcall(function() return request(opts) end)
        if ok and res then
            local decoded = HttpService:JSONDecode(res.Body)
            if decoded and decoded.ok then
                overlay:Destroy()
                local key = decoded.key or (decoded.keys and decoded.keys[1]) or "?"
                notify("🔑 Key Generated", key, 5)
                pcall(function() setclipboard(key) end)
                if refreshCallback then refreshCallback() end
            else
                genBtn.Text = "🔑 CREATE KEY"
                genBtn.BackgroundColor3 = Config.Colors.Accent
                notify("❌ Gagal", decoded and decoded.error or "Unknown", 3)
            end
        else
            genBtn.Text = "🔑 CREATE KEY"
            genBtn.BackgroundColor3 = Config.Colors.Accent
            notify("❌ Network Error", "Coba lagi", 3)
        end
    end)
end

function KeyManagerWindow.showEditModalInternal(parentGui, Config, Utils, modules, notify, keyData, refreshCallback)
    local gui = parentGui
    
    local overlay, modal = makeModalBase(gui, Config, Utils, "EDIT KEY", 340, 460)
    
    local keyLbl = Instance.new("TextLabel", modal)
    keyLbl.Size = UDim2.new(1, -24, 0, 14)
    keyLbl.Position = UDim2.new(0, 12, 0, 36)
    keyLbl.BackgroundTransparency = 1
    keyLbl.Font = Config.Fonts.Mono
    keyLbl.Text = keyData.key
    keyLbl.TextColor3 = Config.Colors.Muted
    keyLbl.TextSize = 10
    keyLbl.TextXAlignment = Enum.TextXAlignment.Left
    keyLbl.ZIndex = 902
    
    local scroll = makeScrollContent(modal, Config, 56, 56)
    
    local tierInput = makeInputRow(scroll, Config, Utils, "Tier:", "", keyData.tier)
    tierInput.Parent.LayoutOrder = 1
    
    local usageInput = makeInputRow(scroll, Config, Utils, "Max Usage:", "", keyData.maxUsage)
    usageInput.Parent.LayoutOrder = 2
    
    local noteInput = makeInputRow(scroll, Config, Utils, "Note:", "", keyData.note)
    noteInput.Parent.LayoutOrder = 3
    
    local durationLabel = Instance.new("TextLabel", scroll)
    durationLabel.Size = UDim2.new(1, 0, 0, 16)
    durationLabel.BackgroundTransparency = 1
    durationLabel.Font = Config.Fonts.Title
    durationLabel.Text = "Extend Duration:"
    durationLabel.TextColor3 = Config.Colors.Text
    durationLabel.TextSize = 10
    durationLabel.TextXAlignment = Enum.TextXAlignment.Left
    durationLabel.ZIndex = 903
    durationLabel.LayoutOrder = 4
    
    local durationPicker = modules.DurationPicker.new(scroll, {}, Config, Utils, nil)
    durationPicker.LayoutOrder = 5
    
    local btnRow = makeButtonRow(modal, Config, Utils)
    
    local saveBtn = makeButton(btnRow, Config, Utils, "💾 SIMPAN", Config.Colors.Accent, 1)
    local cancelBtn = makeButton(btnRow, Config, Utils, "❌ BATAL", Config.Colors.Card, 2)
    
    cancelBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
    
    saveBtn.MouseButton1Click:Connect(function()
        local durData = durationPicker.GetValue()
        
        local body = {
            key = keyData.key,
            tier = tierInput.Text,
            maxUsage = tonumber(usageInput.Text) or keyData.maxUsage,
            note = noteInput.Text,
        }
        
        if durData.unit == "lifetime" then
            body.amount = 0
            body.unit = "lifetime"
        else
            body.amount = durData.amount
            body.unit = durData.unit
        end
        
        local opts = {
            Url = "https://igr-backen.vercel.app/api/key/edit",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["X-User-Id"] = tostring(LocalPlayer.UserId),
            },
            Body = HttpService:JSONEncode(body),
        }
        
        saveBtn.Text = "⏳ LOADING..."
        saveBtn.BackgroundColor3 = Config.Colors.Muted
        
        local ok, res = pcall(function() return request(opts) end)
        if ok and res then
            local decoded = HttpService:JSONDecode(res.Body)
            if decoded and decoded.ok then
                overlay:Destroy()
                notify("💾 Updated", keyData.key, 3)
                if refreshCallback then refreshCallback() end
            else
                saveBtn.Text = "💾 SIMPAN"
                saveBtn.BackgroundColor3 = Config.Colors.Accent
                notify("❌ Gagal", decoded and decoded.error or "Unknown", 3)
            end
        else
            saveBtn.Text = "💾 SIMPAN"
            saveBtn.BackgroundColor3 = Config.Colors.Accent
            notify("❌ Network Error", "Coba lagi", 3)
        end
    end)
end

function KeyManagerWindow.showRevokeConfirmInternal(parentGui, Config, Utils, modules, notify, keyData, refreshCallback)
    local gui = parentGui
    
    local overlay, modal = makeModalBase(gui, Config, Utils, "REVOKE KEY?", 300, 200)
    
    local m = Instance.new("TextLabel", modal)
    m.Size = UDim2.new(1, -20, 1, -100)
    m.Position = UDim2.new(0, 10, 0, 40)
    m.BackgroundTransparency = 1
    m.Font = Config.Fonts.Mono
    m.Text = "Key:\n" .. keyData.key .. "\n\nYakin mau revoke?"
    m.TextColor3 = Config.Colors.Text
    m.TextSize = 10
    m.TextWrapped = true
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.ZIndex = 902
    
    local btnRow = makeButtonRow(modal, Config, Utils)
    
    local okBtn = makeButton(btnRow, Config, Utils, "🔨 REVOKE", Config.Colors.Danger, 1)
    local cancelBtn = makeButton(btnRow, Config, Utils, "❌ BATAL", Config.Colors.Card, 2)
    
    cancelBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
    
    okBtn.MouseButton1Click:Connect(function()
        local opts = {
            Url = "https://igr-backen.vercel.app/api/key/revoke",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["X-User-Id"] = tostring(LocalPlayer.UserId),
            },
            Body = HttpService:JSONEncode({
                key = keyData.key,
                deleteUser = false,
            }),
        }
        
        okBtn.Text = "⏳ LOADING..."
        okBtn.BackgroundColor3 = Config.Colors.Muted
        
        local ok, res = pcall(function() return request(opts) end)
        if ok and res then
            local decoded = HttpService:JSONDecode(res.Body)
            if decoded and decoded.ok then
                overlay:Destroy()
                notify("🔨 Revoked", keyData.key, 3)
                if refreshCallback then refreshCallback() end
            else
                okBtn.Text = "🔨 REVOKE"
                okBtn.BackgroundColor3 = Config.Colors.Danger
                notify("❌ Gagal", decoded and decoded.error or "Unknown", 3)
            end
        else
            okBtn.Text = "🔨 REVOKE"
            okBtn.BackgroundColor3 = Config.Colors.Danger
            notify("❌ Network Error", "Coba lagi", 3)
        end
    end)
end

return KeyManagerWindow
