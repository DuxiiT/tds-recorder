local screen_gui = Instance.new("ScreenGui", core_gui)
screen_gui.Name = "strat_recorder_ui"

local main_frame = Instance.new("Frame", screen_gui)
main_frame.Size = UDim2.new(0, 350, 0, 480)
main_frame.Position = UDim2.new(0.5, -175, 0.5, -240)
main_frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main_frame.Active = true
main_frame.Draggable = true
Instance.new("UICorner", main_frame)

local title_label = Instance.new("TextLabel", main_frame)
title_label.Size = UDim2.new(1, -40, 0, 40)
title_label.Position = UDim2.new(0, 10, 0, 0)
title_label.Text = "Strat Recorder"
title_label.TextColor3 = Color3.new(1, 1, 1)
title_label.BackgroundTransparency = 1
title_label.Font = Enum.Font.GothamBold
title_label.TextSize = 18
title_label.TextXAlignment = Enum.TextXAlignment.Left

local close_btn = Instance.new("TextButton", main_frame)
close_btn.Size = UDim2.new(0, 30, 0, 30)
close_btn.Position = UDim2.new(1, -35, 0, 5)
close_btn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
close_btn.Text = "×"
close_btn.TextColor3 = Color3.fromRGB(255, 100, 100)
Instance.new("UICorner", close_btn)

-- COOLDOWN STATUS BAR
local status_label = Instance.new("TextLabel", main_frame)
status_label.Size = UDim2.new(0.9, 0, 0, 20)
status_label.Position = UDim2.new(0.05, 0, 0.65, 0)
status_label.Text = "UPGRADE READY"
status_label.TextColor3 = Color3.fromRGB(150, 150, 150)
status_label.BackgroundTransparency = 1
status_label.Font = Enum.Font.GothamBold
status_label.TextSize = 10

local cooldown_bg = Instance.new("Frame", main_frame)
cooldown_bg.Size = UDim2.new(0.9, 0, 0, 6)
cooldown_bg.Position = UDim2.new(0.05, 0, 0.7, 0)
cooldown_bg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", cooldown_bg)

local cooldown_bar = Instance.new("Frame", cooldown_bg)
cooldown_bar.Size = UDim2.new(1, 0, 1, 0)
cooldown_bar.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
Instance.new("UICorner", cooldown_bar)

local log_box = Instance.new("ScrollingFrame", main_frame)
log_box.Size = UDim2.new(0.9, 0, 0, 180)
log_box.Position = UDim2.new(0.05, 0, 0.22, 0)
log_box.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
log_box.ScrollBarThickness = 4

local log_layout = Instance.new("UIListLayout", log_box)
log_layout.Padding = UDim.new(0, 5)

local start_btn = Instance.new("TextButton", main_frame)
start_btn.Size = UDim2.new(0.4, 0, 0, 40)
start_btn.Position = UDim2.new(0.05, 0, 0.78, 0)
start_btn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
start_btn.Text = "START"
start_btn.Font = Enum.Font.GothamBold
start_btn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", start_btn)

local stop_btn = Instance.new("TextButton", main_frame)
stop_btn.Size = UDim2.new(0.4, 0, 0, 40)
stop_btn.Position = UDim2.new(0.55, 0, 0.78, 0)
stop_btn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
stop_btn.Text = "STOP"
stop_btn.Font = Enum.Font.GothamBold
stop_btn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", stop_btn)

local function add_log(msg)
    local log_item = Instance.new("TextLabel", log_box)
    log_item.Size = UDim2.new(1, -10, 0, 20)
    log_item.BackgroundTransparency = 1
    log_item.TextColor3 = Color3.fromRGB(200, 200, 200)
    log_item.Text = "> " .. msg
    log_item.Font = Enum.Font.Code
    log_item.TextSize = 12
    log_item.TextXAlignment = Enum.TextXAlignment.Left
    log_box.CanvasSize = UDim2.new(0, 0, 0, log_layout.AbsoluteContentSize.Y)
    log_box.CanvasPosition = Vector2.new(0, log_box.CanvasSize.Y.Offset)
end

local function update_cooldown_ui()
    local now = tick()
    local elapsed = now - last_upgrade_time
    local progress = math.clamp(elapsed / cooldown_duration, 0, 1)
    
    cooldown_bar.Size = UDim2.new(progress, 0, 1, 0)
    
    if progress >= 1 then
        status_label.Text = "UPGRADE READY"
        cooldown_bar.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    else
        status_label.Text = "COOLDOWN..."
        cooldown_bar.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    end
end

-- Task to keep bar updated
task.spawn(function()
    while task.wait(0.05) do
        if screen_gui.Parent then update_cooldown_ui() else break end
    end
end)

local towers_folder = workspace_service:WaitForChild("Towers")
local upgrades_gui = player:WaitForChild("PlayerGui"):WaitForChild("ReactUpgrades").upgrades

local function monitor_tower(new_tower)
    if not _G.record_strat then return end
    
    local timer = 0
    while not upgrades_gui.Visible and timer < 5 do
        if not _G.record_strat then return end 
        task.wait(0.1)
        timer = timer + 0.1
    end

    tower_count = tower_count + 1
    local tower_id = tower_count
    local tower_name = upgrades_gui.controlPanel.displayFrame.titleText.Text
    local pivot_pos = new_tower:GetPivot().Position
    
    local place_cmd = string.format('TDS:Place("%s", %0.2f, %0.2f, %0.2f)', tower_name, pivot_pos.X, pivot_pos.Y, pivot_pos.Z)
    add_log("Placed #" .. tower_id .. ": " .. tower_name)
    if appendfile then appendfile(file_name, place_cmd .. "\n") end

    local upgrades_root = new_tower:WaitForChild("Upgrades", 10)
    if not upgrades_root then return end

    local function trigger_upgrade()
        if not _G.record_strat then return end
        local now = tick()
        if (now - last_upgrade_time) < cooldown_duration then return end
        
        last_upgrade_time = now
        local upgrade_cmd = string.format('TDS:Upgrade(%d)', tower_id)
        add_log("Upgraded #" .. tower_id)
        if appendfile then appendfile(file_name, upgrade_cmd .. "\n") end
    end

    local function watch_node(obj)
        local connection = obj.Changed:Connect(function(prop)
            if prop ~= "Parent" and prop ~= "CFrame" and prop ~= "Position" then
                trigger_upgrade()
            end
        end)
        table.insert(tower_connections, connection)
    end

    for _, desc in ipairs(upgrades_root:GetDescendants()) do watch_node(desc) end
    
    local added_conn = upgrades_root.DescendantAdded:Connect(function(desc)
        watch_node(desc)
        trigger_upgrade()
    end)
    table.insert(tower_connections, added_conn)
end

start_btn.MouseButton1Click:Connect(function()
    _G.record_strat = true
    tower_count = 0 
    for _, child in ipairs(log_box:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    add_log("--- RECORDING STARTED ---")
    if writefile then writefile(file_name, "-- Strat: --\n") end
end)

stop_btn.MouseButton1Click:Connect(function()
    _G.record_strat = false
    for _, conn in ipairs(tower_connections) do
        if conn then conn:Disconnect() end
    end
    tower_connections = {}
    add_log("--- RECORDING STOPPED ---")
end)

close_btn.MouseButton1Click:Connect(function()
    _G.record_strat = false
    screen_gui:Destroy()
end)

towers_folder.ChildAdded:Connect(function(new_tower)
    if not _G.record_strat then return end
    task.spawn(function() monitor_tower(new_tower) end)
end)

add_log("System Ready. Press Start.")
