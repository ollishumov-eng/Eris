-- Eris Hub
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local REP = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local SS = game:GetService("SoundService")

local plr = Players.LocalPlayer
local pgui = plr:WaitForChild("PlayerGui")
local cam = workspace.CurrentCamera

local IS_TOUCH = UIS.TouchEnabled and not UIS.KeyboardEnabled
local IS_MOBILE = UIS.TouchEnabled

for _, n in ipairs({"ErisHub", "ErisCursor", "ErisDropdownGui"}) do
    local o = pgui:FindFirstChild(n)
    if o then o:Destroy() end
end

local ACCENT = Color3.fromRGB(0, 200, 255)
local ACCENT2 = Color3.fromRGB(120, 220, 255)
local DARK = Color3.fromRGB(15, 18, 24)
local NOTIFY_SOUND = "rbxassetid://128418218662188"
local TRACE_TEXTURE = "rbxassetid://8725614868"
local DISCORD_LINK = "https://discord.gg/BUDrNepGhd"

local function getExecutor()
    local ok, name = pcall(function()
        if identifyexecutor then return identifyexecutor() end
        return nil
    end)
    if ok and name then return name end
    if syn then return "Synapse" end
    if KRNL_LOADED then return "Krnl" end
    if is_sirhurt_closure then return "SirHurt" end
    if secure_load then return "Sentinel" end
    if fluxus then return "Fluxus" end
    return "Unknown"
end

local EXECUTOR_NAME = getExecutor()
local START_TIME = os.clock()

local function getAccountDate()
    local ok, age = pcall(function() return plr.AccountAge end)
    if not ok or not age then return "N/A" end
    local now = os.time()
    local created = now - age * 86400
    local ok2, dateStr = pcall(function()
        return os.date("%d.%m.%Y", created)
    end)
    if ok2 and dateStr then return dateStr end
    return "N/A"
end

local function getAccountAge()
    local ok, age = pcall(function() return plr.AccountAge end)
    if ok and age then
        local days = age
        local years = math.floor(days / 365)
        local months = math.floor((days % 365) / 30)
        local d = days % 30
        if years > 0 then return years .. "y " .. months .. "m" end
        if months > 0 then return months .. "m " .. d .. "d" end
        return d .. "d"
    end
    return "N/A"
end

local S = {
    antiOwn = false, antiOwnTask = nil,
    agProc = false, agWalk = false, agConns = {},
    ownKick = false, ownKickTask = nil,
    ownRag = false, ownRagTask = nil,
    loopKill = false, loopKillTask = nil,
    snowball = false, snowballTask = nil,
    destroyGucci = false, destroyGucciTask = nil,
    antiInput = false, antiInputTask = nil,
    antiKick = false, antiKickTask = nil,
    loopKickBlob = false, loopApple = false,
    autoSit = false,
    traceOn = false, traceBeam = nil, traceConn = nil, traceTarget = nil,
    espOn = false, espBoxes = {},
    espColor = Color3.fromRGB(255, 255, 255),
    pktNotify = false, pktCooldown = false,
    target = nil,
    notifyConns = {},
    openDropdowns = {},
}

local ESP_TARGETS = {"partesp", "playercharacterlocationdetector"}

local function FWC(o, n) return o:FindFirstChild(n) or o:WaitForChild(n, 3) end
local function discAG(k) if S.agConns[k] then S.agConns[k]:Disconnect(); S.agConns[k] = nil end end
local function playerList()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then table.insert(t, p.DisplayName) end
    end
    return t
end
local function findPlayerByDisplay(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.DisplayName == name or p.Name == name then return p end
    end
    return nil
end
local function closestPlayer(pos)
    if not pos then return nil end
    local best, bestD = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        local h = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if h then
            local d = (h.Position - pos).Magnitude
            if d < bestD then bestD, best = d, p end
        end
    end
    return best
end

local function antiOwnershipLoop()
    local St = REP.CharacterEvents.Struggle
    while S.antiOwn do
        local c = plr.Character
        local head = c and c:FindFirstChild("Head")
        if head and head:FindFirstChild("PartOwner") then
            St:FireServer(plr)
            for _, p in ipairs(c:GetChildren()) do if p:IsA("BasePart") then p.Anchored = true end end
            local held = plr:FindFirstChild("IsHeld")
            while held and held.Value and S.antiOwn do task.wait() end
            for _, p in ipairs(c:GetChildren()) do if p:IsA("BasePart") then p.Anchored = false end end
        end
        task.wait(0.1)
    end
end

local function deleteLegs()
    local c = plr.Character or plr.CharacterAdded:Wait()
    local l, r = c:FindFirstChild("Left Leg"), c:FindFirstChild("Right Leg")
    local t = c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
    local h = c:FindFirstChild("HumanoidRootPart")
    if not (l and r and t and h) then return end
    local old = workspace.FallenPartsDestroyHeight
    local cf = t.CFrame
    workspace.FallenPartsDestroyHeight = -100
    REP.CharacterEvents.RagdollRemote:FireServer(h, 2)
    task.wait(0.5)
    l.CFrame = CFrame.new(0, -10000, 0)
    r.CFrame = CFrame.new(0, -10000, 0)
    task.wait(0.3)
    t.CFrame = CFrame.new(0, -9970, 0)
    task.wait(0.5)
    t.CFrame = cf
    task.wait(0.5)
    workspace.FallenPartsDestroyHeight = old
end

local function shurikenLoop()
    local setOwner = REP:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
    local sticky = REP:WaitForChild("PlayerEvents"):WaitForChild("StickyPartEvent")
    local spawn = REP.MenuToys.SpawnToyRemoteFunction
    local destroy = REP:WaitForChild("MenuToys"):WaitForChild("DestroyToy")
    local canSpawn = plr:WaitForChild("CanSpawnToy")
    local function getHRP()
        local c = plr.Character
        if c and c:FindFirstChild("HumanoidRootPart") then return c.HumanoidRootPart end
        return plr.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
    end
    local function stick(k)
        if not k or not k:FindFirstChild("StickyPart") then return end
        local h = getHRP()
        if not h then return end
        local sp = k:FindFirstChild("SoundPart")
        if sp and (not sp:FindFirstChild("PartOwner") or sp.PartOwner.Value ~= plr.Name) then
            setOwner:FireServer(sp, sp.CFrame)
        end
        local fp = h:FindFirstChild("FirePlayerPart") or h:WaitForChild("FirePlayerPart", 5)
        if fp then
            sticky:FireServer(k.StickyPart, fp, CFrame.Angles(0, math.rad(90), math.rad(90)))
        end
    end
    local function spawnToy(name)
        local t = tick()
        while not canSpawn.Value do
            if not _G.ShurikenAntiKick or tick() - t > 5 then return nil end
            task.wait(0.1)
        end
        pcall(function()
            spawn:InvokeServer(name, getHRP().CFrame * CFrame.new(0, 12, 20), Vector3.zero)
        end)
        local inv = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
        if inv and not workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then
            return inv:WaitForChild(name, 2)
        end
        return nil
    end
    while _G.ShurikenAntiKick do
        task.wait(0.05)
        local c = plr.Character
        if not c or not c:FindFirstChild("Humanoid") or c.Humanoid.Health <= 0 then continue end
        if workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then continue end
        local inv = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
        local k = inv and (inv:FindFirstChild("AntiKick") or inv:FindFirstChild("NinjaShuriken"))
        if not k then
            k = spawnToy("NinjaShuriken")
            if k then k.Name = "AntiKick" end
        end
        if k then stick(k) end
    end
    local inv = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
    if inv then
        for _, v in ipairs(inv:GetChildren()) do
            if v.Name == "AntiKick" or v.Name == "NinjaShuriken" then
                pcall(function() destroy:FireServer(v) end)
            end
        end
    end
end

local function destroyGucci(p)
    if not p or p == plr or not p.Character then return end
    local folder = workspace:FindFirstChild(p.Name .. "SpawnedInToys")
    if not folder then return end
    for _, o in ipairs(folder:GetChildren()) do
        if o.Name == "CreatureBlobman" then
            local seat = o:FindFirstChildWhichIsA("VehicleSeat", true)
            if seat then
                local c = plr.Character
                local hum = c and c:FindFirstChild("Humanoid")
                local root = c and c:FindFirstChild("HumanoidRootPart")
                if hum and root then
                    local old = root.CFrame
                    root.CFrame = seat.CFrame
                    root.Velocity = Vector3.zero
                    seat:Sit(hum)
                    task.wait(0.3)
                    if hum.SeatPart == seat then
                        hum.Sit = false
                        task.wait(0.1)
                        root.CFrame = old
                        task.wait(0.5)
                        o:Destroy()
                        return
                    end
                    root.CFrame = old
                end
            end
        end
    end
end

local function destroyGucciLoop()
    while S.destroyGucci do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= plr then destroyGucci(p) end
        end
        task.wait(2)
    end
end

local function removeAntiInputLoop()
    local allowed = {
        FoodHamburger=true, FoodCoconut=true, FoodPizzaCheese=true, FoodPizzaPepperoni=true,
        FoodHotdog=true, FoodMushroomPoison=true, FoodBread=true, FoodDippyEgg=true,
        FoodMayonnaise=true, FoodFrenchFries=true, FoodMeatStick=true, FoodDonut=true,
        FoodCakePink=true, InstrumentGuitarBanjo=true, InstrumentGuitarViolin=true,
        InstrumentGuitarUkulele=true, InstrumentWoodwindSaxophone=true,
        InstrumentBrassTrumpet=true, InstrumentDrumBongos=true, InstrumentDrumSnare=true,
        InstrumentPianoMelodica=true, InstrumentVoiceMicrophone=true,
        CupMugWhite=true, CupMugBrown=true, PoopPile=true, PoopPileSparkle=true,
    }
    local c = plr.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    if not h then return end
    local items = {}
    local conn = workspace.DescendantAdded:Connect(function(o)
        if allowed[o.Name] and o:IsA("Model") then
            task.spawn(function() if o:WaitForChild("HoldPart", 3) then table.insert(items, o) end end)
        end
    end)
    for _, v in ipairs(workspace:GetDescendants()) do
        if allowed[v.Name] and v:IsA("Model") and v:FindFirstChild("HoldPart") then
            table.insert(items, v)
        end
    end
    while S.antiInput do
        for i = #items, 1, -1 do
            local b = items[i]
            if not b or not b.Parent or not b:FindFirstChild("HoldPart") then
                table.remove(items, i)
            else
                local hp = b.HoldPart
                pcall(function() hp.HoldItemRemoteFunction:InvokeServer(b, c) end)
                task.wait()
                pcall(function()
                    hp.DropItemRemoteFunction:InvokeServer(b, CFrame.new(h.Position + Vector3.new(0, -2000, 0)), Vector3.zero)
                end)
            end
        end
        task.wait()
    end
    conn:Disconnect()
end

local function ownershipKick(targetName)
    local target = Players:FindFirstChild(targetName)
    if not target then return end
    local GE = REP:WaitForChild("GrabEvents")
    local c = plr.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local saved = root.CFrame
    local dragging, grabT, checkT = false, 0, 0
    local fps = 60
    local fpsConn = RS.RenderStepped:Connect(function(dt) fps = 1 / dt end)
    local bp, bg
    local function clear()
        if bp then bp:Destroy() bp = nil end
        if bg then bg:Destroy() bg = nil end
    end
    local function createBodies(tr, pos)
        clear()
        for _, v in pairs(tr:GetChildren()) do
            if v:IsA("BodyPosition") or v:IsA("BodyGyro") then v:Destroy() end
        end
        bp = Instance.new("BodyPosition", tr)
        bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bp.D = 100
        bp.Position = pos
        bg = Instance.new("BodyGyro", tr)
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.D = 100
        bg.CFrame = CFrame.new(pos)
    end
    while S.ownKick do
        local cur = Players:FindFirstChild(target.Name)
        if not cur or not cur.Parent then clear(); break end
        c = plr.Character
        root = c and c:FindFirstChild("HumanoidRootPart")
        local tc = cur.Character
        local tr = tc and tc:FindFirstChild("HumanoidRootPart")
        local th = tc and tc:FindFirstChild("Humanoid")
        if tr and th and th.Health > 0 and root then
            if not dragging then
                root.CFrame = tr.CFrame * CFrame.new(0, 0, 3)
                clear()
                pcall(function()
                    th.PlatformStand = true; th.Sit = true
                    GE.SetNetworkOwner:FireServer(tr, tr.CFrame)
                    GE.SetNetworkOwner:FireServer(tr, tr.CFrame)
                    GE.DestroyGrabLine:FireServer(tr)
                end)
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                if grabT == 0 then grabT = tick() end
                if tick() - grabT > 0.35 then
                    dragging = true; grabT = 0; checkT = tick()
                    createBodies(tr, (saved * CFrame.new(0, 17, 0)).Position)
                end
            else
                root.CFrame = saved
                local lock = saved * CFrame.new(0, 17, 0)
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                if bp and bp.Parent then
                    bp.Position = lock.Position
                    if bg then bg.CFrame = lock end
                else
                    createBodies(tr, lock.Position)
                end
                th.PlatformStand = true
                local n = fps > 200 and 2 or (fps >= 155 and 3 or 4)
                pcall(function()
                    for i = 1, n do GE.SetNetworkOwner:FireServer(tr, lock) end
                    GE.DestroyGrabLine:FireServer(tr)
                end)
                if checkT > 0 and tick() - checkT > 0.3 then
                    if (tr.Position - lock.Position).Magnitude > 10 then
                        dragging, grabT, checkT = false, 0, 0
                        clear()
                        root.CFrame = tr.CFrame * CFrame.new(0, 0, 3)
                    else checkT = tick() end
                end
            end
        else
            dragging, grabT, checkT = false, 0, 0
            clear()
        end
        RS.Heartbeat:Wait()
    end
    fpsConn:Disconnect()
    clear()
    if root then root.CFrame = saved end
end

local function palletRagdoll(targetName)
    local t = Players:FindFirstChild(targetName)
    if not t or not t.Character then return end
    local GE = REP:WaitForChild("GrabEvents")
    local sky = CFrame.new(0, 800000, 0)
    REP.MenuToys.SpawnToyRemoteFunction:InvokeServer("PalletLightBrown", sky, Vector3.zero)
    local pallet
    repeat
        local f = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
        pallet = f and f:FindFirstChild("PalletLightBrown")
        RS.Heartbeat:Wait()
    until pallet or not S.ownRag
    if not pallet then return end
    local main = pallet:FindFirstChild("SoundPart")
    if not main then return end
    main.CanCollide = false
    main.Anchored = false
    local function claim(p)
        GE.SetNetworkOwner:FireServer(p, p.CFrame)
        GE.CreateGrabLine:FireServer(p, Vector3.zero, p.Position, false)
        GE.DestroyGrabLine:FireServer(p)
    end
    claim(main)
    while S.ownRag do
        for i = 1, 20 do RS.Heartbeat:Wait() end
        if not t.Parent or not t.Character then break end
        local head = t.Character:FindFirstChild("Head")
        if head then
            main.CFrame = CFrame.new(head.Position.X, head.Position.Y + 0.2, head.Position.Z)
            main.AssemblyLinearVelocity = Vector3.zero
            main.AssemblyAngularVelocity = Vector3.new(1000, 1000, 1000)
            claim(main)
            main.CanCollide = true
            for i = 1, 3 do RS.Heartbeat:Wait() end
            main.CanCollide = false
            main.CFrame = sky
            main.AssemblyAngularVelocity = Vector3.zero
        end
    end
    pcall(function() REP.MenuToys.DestroyToy:FireServer(pallet) end)
    if pallet.Parent then pallet:Destroy() end
end

local function loopKill(targetName)
    local t = Players:FindFirstChild(targetName)
    if not t then return end
    local GE = REP:WaitForChild("GrabEvents")
    while S.loopKill and t.Parent do
        local tc = t.Character
        local c = plr.Character
        local root = c and c:FindFirstChild("HumanoidRootPart")
        local tr = tc and tc:FindFirstChild("HumanoidRootPart")
        local th = tc and tc:FindFirstChild("Humanoid")
        if tr and th and th.Health > 0 and root then
            local back = root.CFrame
            local start = tick()
            while tick() - start < 0.35 and S.loopKill do
                if not tr.Parent then break end
                root.CFrame = tr.CFrame * CFrame.new(0, 0, 2)
                root.Velocity = Vector3.zero
                pcall(function()
                    GE.SetNetworkOwner:FireServer(tr, root.CFrame)
                    th:ChangeState(Enum.HumanoidStateType.Dead)
                    th.Health = 0
                    GE.CreateGrabLine:FireServer(tr, Vector3.zero, tr.Position, false)
                    GE.DestroyGrabLine:FireServer(tr)
                end)
                RS.Heartbeat:Wait()
            end
            root.CFrame = back
            root.Velocity = Vector3.zero
            task.wait(1.2)
        else task.wait(0.5) end
    end
end

local function snowballRagdoll(targetName)
    local t = Players:FindFirstChild(targetName)
    if not t then return end
    local spawn = REP:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
    while S.snowball do
        if not t.Parent then break end
        local tc = t.Character
        local torso = tc and (tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso"))
        if torso then
            local o = Vector3.new(math.random(-30,30)/100, math.random(-30,30)/100, math.random(-30,30)/100)
            pcall(function() spawn:InvokeServer("BallSnowball", torso.CFrame * CFrame.new(o), Vector3.zero) end)
            local folder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
            if folder then
                for _, sb in ipairs(folder:GetChildren()) do
                    if sb.Name == "BallSnowball" and sb.Parent then
                        local part = sb.PrimaryPart or sb:FindFirstChildWhichIsA("BasePart")
                        if part then
                            part.CFrame = torso.CFrame * CFrame.new(o)
                            part.AssemblyLinearVelocity = Vector3.zero
                            part.AssemblyAngularVelocity = Vector3.zero
                        end
                    end
                end
            end
        end
        task.wait()
    end
end

local function removeAntiKick(targetName)
    local setOwner = REP.GrabEvents.SetNetworkOwner
    local function yeet(toy)
        local sp = toy:FindFirstChild("SoundPart")
        if sp then
            setOwner:FireServer(sp, sp.CFrame)
            if sp:FindFirstChild("PartOwner") and sp.PartOwner.Value == plr.Name then
                sp.CFrame = CFrame.new(0, 1000, 0)
            end
        end
    end
    while S.antiKick do
        local t = Players:FindFirstChild(targetName)
        if t then
            local sp = workspace:FindFirstChild(t.Name .. "SpawnedInToys")
            if sp then
                for _, n in ipairs({"NinjaKunai", "NinjaShuriken", "AntiKick"}) do
                    local toy = sp:FindFirstChild(n)
                    if toy then yeet(toy) end
                end
            end
        end
        task.wait(0.1)
    end
end

local function blobKick(blob, hrp, rl, v)
    local det = blob:FindFirstChild(rl .. "Detector")
    if not det then return end
    local s = blob.BlobmanSeatAndOwnerScript
    if v == "Default" then s.CreatureGrab:FireServer(det, hrp, det[rl .. "Weld"])
    elseif v == "DDrop" then s.CreatureDrop:FireServer(det[rl .. "Weld"])
    elseif v == "Release" then s.CreatureRelease:FireServer(det[rl .. "Weld"], hrp) end
end

local function waitMyBlob()
    while true do
        local c = plr.Character or plr.CharacterAdded:Wait()
        local h = FWC(c, "Humanoid")
        if h and h.SeatPart then return h.SeatPart.Parent end
        task.wait()
    end
end

local function blobKill(targetName)
    local target = Players:FindFirstChild(targetName)
    local myBlob = waitMyBlob()
    local grab = function(p) REP.GrabEvents.SetNetworkOwner:FireServer(p, p.CFrame) end
    local run = true
    while run do
        local c = plr.Character
        local h = c and FWC(c, "Humanoid")
        if not h or not h.SeatPart or h.SeatPart.Parent ~= myBlob then break end
        local t = Players:FindFirstChild(targetName)
        if t and t.Character then
            local th = FWC(t.Character, "Humanoid", 2)
            local tr = FWC(t.Character, "HumanoidRootPart", 2)
            if th and tr and th.Health > 0 then
                local LD = myBlob:FindFirstChild("LeftDetector")
                local LW = LD and LD:FindFirstChild("LeftWeld")
                if LW then
                    local myHRP = FWC(c, "HumanoidRootPart")
                    local saved = myHRP.CFrame
                    while th.SeatPart do task.spawn(grab, tr); task.wait() end
                    for i = 1, 4 do
                        if not h.SeatPart then run = false; break end
                        myHRP.CFrame = tr.CFrame - Vector3.new(0, 10, 0)
                        blobKick(myBlob, tr, "Left", "Default")
                        task.wait(0.05)
                        blobKick(myBlob, tr, "Left", "Release")
                        th.Health = 0
                        task.wait()
                    end
                    myHRP.CFrame = saved
                end
            end
        end
        task.wait()
    end
end

local function blobHeal(targetName)
    local myBlob = waitMyBlob()
    local grab = function(p) REP.GrabEvents.SetNetworkOwner:FireServer(p, p.CFrame) end
    local function DoHeal()
        local c = plr.Character
        local myHRP = FWC(c, "HumanoidRootPart")
        local h = FWC(c, "Humanoid")
        if not h.SeatPart or h.SeatPart.Parent ~= myBlob then return false end
        local t = Players:FindFirstChild(targetName)
        if not t or not t.Character then return false end
        local th = t.Character:FindFirstChild("Humanoid")
        local tr = t.Character:FindFirstChild("HumanoidRootPart")
        if not (th and tr) then return false end
        local LD = myBlob:FindFirstChild("LeftDetector")
        if not (LD and LD.LeftWeld) then return false end
        local saved = myHRP.CFrame
        task.spawn(grab, tr)
        task.wait(0.1)
        for i = 1, 3 do
            myHRP.CFrame = tr.CFrame * CFrame.new(0, 0, -2.5)
            blobKick(myBlob, tr, "Left", "Default")
            task.wait(0.08)
            blobKick(myBlob, tr, "Left", "Release")
            th.Health = th.MaxHealth
            task.wait(0.08)
        end
        myHRP.CFrame = saved
        return true
    end
    if not DoHeal() then task.wait(0.5); DoHeal() end
end

local function bringFunc(targetName)
    local target = Players:FindFirstChild(targetName)
    if not target or target == plr then return end
    local c = plr.Character or plr.CharacterAdded:Wait()
    local h = c:WaitForChild("Humanoid")
    local root = c:WaitForChild("HumanoidRootPart")
    local seat = h.SeatPart
    if not seat then return end
    local tc = target.Character or target.CharacterAdded:Wait()
    local tr = tc:WaitForChild("HumanoidRootPart")
    local det = seat.Parent:WaitForChild("LeftDetector")
    local weld = det:WaitForChild("LeftWeld")
    local grabRemote = seat.Parent.BlobmanSeatAndOwnerScript:WaitForChild("CreatureGrab")
    local back = root.CFrame
    local trans = {}
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then trans[p] = p.Transparency; p.Transparency = 1 end
    end
    root.CFrame = tr.CFrame * CFrame.new(0, 0, 2.5)
    task.wait()
    grabRemote:FireServer(det, tr, weld)
    task.delay(0.1, function() grabRemote:FireServer(det, tr, weld) end)
    task.delay(0.2, function()
        root.CFrame = back
        for p, t in pairs(trans) do if p.Parent then p.Transparency = t end end
    end)
end

local function kickFunc(targetName)
    local t = Players:FindFirstChild(targetName)
    if not t then return end
    local c = plr.Character or plr.CharacterAdded:Wait()
    local h = c:WaitForChild("Humanoid")
    local root = c:WaitForChild("HumanoidRootPart")
    local seat = h.SeatPart
    if not seat then return end
    local tc = t.Character or t.CharacterAdded:Wait()
    local tr = tc:WaitForChild("HumanoidRootPart")
    local det = seat.Parent:WaitForChild("LeftDetector")
    local weld = det:WaitForChild("LeftWeld")
    local grab = seat.Parent.BlobmanSeatAndOwnerScript:WaitForChild("CreatureGrab")
    local drop = seat.Parent.BlobmanSeatAndOwnerScript:WaitForChild("CreatureDrop")
    local back = root.CFrame
    root.CFrame = tr.CFrame * CFrame.new(0, 0, 3)
    task.wait(0.5)
    grab:FireServer(det, tr, weld)
    task.wait(0.7)
    drop:FireServer(weld, tr)
    task.wait(0.3)
    grab:FireServer(det, tr, weld)
    local bp = Instance.new("BodyPosition", tr)
    bp.Position = Vector3.new(0, 999e5000, 0)
    bp.MaxForce = Vector3.new(0, 99999e990, 0)
    task.wait(0.6)
    grab:FireServer(det, tr, weld)
    bp:Destroy()
    root.CFrame = back
end

local function loopKickFunc(targetName)
    local t = Players:FindFirstChild(targetName)
    if not t or t == plr then return end
    local c = plr.Character or plr.CharacterAdded:Wait()
    local h = c:WaitForChild("Humanoid")
    local root = c:WaitForChild("HumanoidRootPart")
    local seat = h.SeatPart
    if not seat then return end
    local tc = t.Character or t.CharacterAdded:Wait()
    local th = tc:WaitForChild("Humanoid")
    local tr = tc:WaitForChild("HumanoidRootPart")
    local lD = seat.Parent:WaitForChild("LeftDetector")
    local lW = lD:WaitForChild("LeftWeld")
    local rD = seat.Parent:WaitForChild("RightDetector")
    local rW = rD:WaitForChild("RightWeld")
    local grab = seat.Parent.BlobmanSeatAndOwnerScript:WaitForChild("CreatureGrab")
    local drop = seat.Parent.BlobmanSeatAndOwnerScript:WaitForChild("CreatureDrop")
    local back = root.CFrame
    root.CFrame = tr.CFrame * CFrame.new(0, -5, 0)
    task.wait(0.1)
    grab:FireServer(lD, tr, lW)
    task.wait(0.5)
    drop:FireServer(lW, tr)
    task.wait(0.2)
    local bp = Instance.new("BodyPosition", tr)
    bp.Position = Vector3.new(0, 999e6, 0)
    bp.MaxForce = Vector3.new(999e6, 999e6, 999e6)
    grab:FireServer(lD, tr, lW)
    task.wait(0.5)
    drop:FireServer(lW, tr)
    task.wait(0.5)
    while t.Parent and th.Health > 0 do
        grab:FireServer(lD, tr, lW); task.wait()
        drop:FireServer(lW, tr); task.wait()
        grab:FireServer(rD, tr, rW); task.wait()
        drop:FireServer(rW, tr); task.wait()
        grab:FireServer(lD, tr, lW)
        grab:FireServer(rD, tr, rW); task.wait()
        drop:FireServer(lW, tr)
        drop:FireServer(rW, tr); task.wait()
    end
    bp:Destroy()
    root.CFrame = back
end

local function bypassFunc(targetName)
    local t = Players:FindFirstChild(targetName)
    if not t or t == plr then return end
    local c = plr.Character or plr.CharacterAdded:Wait()
    local h = c:WaitForChild("Humanoid")
    local seat = h.SeatPart
    if not seat then return end
    local tc = t.Character or t.CharacterAdded:Wait()
    local th = tc:WaitForChild("Humanoid")
    local tr = tc:WaitForChild("HumanoidRootPart")
    local lD = seat.Parent:WaitForChild("LeftDetector")
    local lW = lD:WaitForChild("LeftWeld")
    local grab = seat.Parent.BlobmanSeatAndOwnerScript:WaitForChild("CreatureGrab")
    local drop = seat.Parent.BlobmanSeatAndOwnerScript:WaitForChild("CreatureDrop")
    task.wait(0.05)
    while t.Parent and th.Health > 0 do        for i = 1, 20 do grab:FireServer(lD, tr, lW) end
        drop:FireServer(lW, tr)
        drop:FireServer(lW, tr)
        task.wait(0.01)
    end
end

local function loopKickBlob(targetName)
    local target = Players:FindFirstChild(targetName)
    if not target then return end
    local c = plr.Character or plr.CharacterAdded:Wait()
    local h = c:WaitForChild("Humanoid")
    local seat = h.SeatPart
    if not seat or seat.Parent.Name ~= "CreatureBlobman" then return end
    local blob = seat.Parent
    local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
    local rDet = blob:WaitForChild("RightDetector")
    local s = blob:WaitForChild("BlobmanSeatAndOwnerScript")
    local CG = s:WaitForChild("CreatureGrab")
    local CD = s:WaitForChild("CreatureDrop")
    local GE = REP:WaitForChild("GrabEvents")
    local saved = blobRoot.CFrame
    local dragging, grabT, lastR = false, 0, 0
    local DELAY = 0.002
    while S.loopKickBlob do
        local cur = Players:FindFirstChild(targetName)
        if not cur then break end
        c = plr.Character
        h = c and c:FindFirstChild("Humanoid")
        seat = h and h.SeatPart
        if not seat or seat.Parent.Name ~= "CreatureBlobman" then break end
        blob = seat.Parent
        blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
        local tr = cur.Character and cur.Character:FindFirstChild("HumanoidRootPart")
        local th = cur.Character and cur.Character:FindFirstChild("Humanoid")
        if tr and th and th.Health > 0 then
            tr.Velocity = Vector3.zero
            if not dragging then
                blobRoot.CFrame = tr.CFrame
                blobRoot.Velocity = Vector3.zero
                if tick() - lastR >= DELAY then
                    lastR = tick()
                    pcall(function()
                        th.PlatformStand = true; th.Sit = true
                        GE.SetNetworkOwner:FireServer(tr, blobRoot.CFrame)
                        GE.DestroyGrabLine:FireServer(tr)
                    end)
                end
                if grabT == 0 then grabT = tick() end
                if tick() - grabT > 0.35 then
                    dragging = true; grabT = 0
                    blobRoot.CFrame = saved
                    blobRoot.Velocity = Vector3.zero
                end
            else
                blobRoot.CFrame = saved
                blobRoot.Velocity = Vector3.zero
                local lock = saved * CFrame.new(0, 23, 0)
                tr.CFrame = lock
                th.PlatformStand = true; th.Sit = true
                if tick() - lastR >= DELAY then
                    lastR = tick()
                    pcall(function()
                        GE.SetNetworkOwner:FireServer(tr, lock)
                        GE.DestroyGrabLine:FireServer(tr)
                        local w = rDet:FindFirstChild("RightWeld") or rDet:FindFirstChildWhichIsA("Weld")
                        if w then CD:FireServer(w); CG:FireServer(rDet, tr, w) end
                    end)
                end
            end
        else dragging, grabT = false, 0 end
        RS.Heartbeat:Wait()
    end
    if blobRoot then blobRoot.CFrame = saved; blobRoot.Velocity = Vector3.zero end
end

local BlobLock = {Running = false, MyBlob = nil, StartPos = nil, LastTP = 0, Time = 0}

function BlobLock:TP(tr)
    local c = plr.Character
    local myHRP = c and FWC(c, "HumanoidRootPart", 2)
    if not myHRP then return end
    self.StartPos = myHRP.CFrame
    myHRP.CFrame = tr.CFrame + Vector3.new(0, 5, 0)
    task.wait(0.05)
    for i = 1, 3 do REP.GrabEvents.SetNetworkOwner:FireServer(tr, tr.CFrame); task.wait() end
    task.wait(0.1)
    myHRP.CFrame = self.StartPos
    self.LastTP = tick()
end

function BlobLock:Start(name)
    if self.Running then return end
    local target = Players:FindFirstChild(name)
    if not target then return end
    self.Running = true
    task.spawn(function()
        local tr = target.Character and FWC(target.Character, "HumanoidRootPart", 2)
        if tr then self:TP(tr) end
        while self.Running do
            task.wait()
            local c = plr.Character
            if not c then continue end
            local myHRP = FWC(c, "HumanoidRootPart", 2)
            local h = FWC(c, "Humanoid", 2)
            if not myHRP or not h or not h.SeatPart then self:Stop(); break end
            self.MyBlob = h.SeatPart.Parent
            local cur = Players:FindFirstChild(name)
            if not cur or not cur.Character then self:Stop(); break end
            local th = FWC(cur.Character, "Humanoid", 2)
            local tr2 = FWC(cur.Character, "HumanoidRootPart", 2)
            if not th or not tr2 or th.Health == 0 then continue end
            local d = (myHRP.Position - tr2.Position).Magnitude
            if d > 15 and tick() - self.LastTP > 0.5 then self:TP(tr2) end
            if self.MyBlob and self.MyBlob.Parent then
                task.defer(function()
                    if tr2:GetNetworkOwner() == plr then
                        if tick() - self.Time > 0.5 then
                            th.Sit = true; task.wait(0.16); th.Sit = false
                            self.Time = tick()
                        end
                        local LD = self.MyBlob:FindFirstChild("LeftDetector")
                        if LD then tr2.CFrame = LD.CFrame end
                        for _, v in ipairs(cur.Character:GetChildren()) do
                            if v:IsA("BasePart") then v.Velocity = Vector3.zero end
                        end
                        if d < 40 and th.SeatPart then
                            REP.GrabEvents.SetNetworkOwner:FireServer(tr2, tr2.CFrame)
                        end
                    end
                end)
                local LD = self.MyBlob:FindFirstChild("LeftDetector")
                if LD then
                    local grab = self.MyBlob.BlobmanSeatAndOwnerScript.CreatureGrab
                    local rel = self.MyBlob.BlobmanSeatAndOwnerScript.CreatureRelease
                    grab:FireServer(LD, tr2, LD.LeftWeld)
                    task.wait(0.005)
                    rel:FireServer(LD.LeftWeld, tr2)
                end
            end
        end
    end)
end

function BlobLock:Stop()
    self.Running = false
    self.MyBlob = nil
end

local function startTraceFor(targetName, onFlag)
    local t = Players:FindFirstChild(targetName)
    if not t then return end
    local p0 = Instance.new("Part", WS)
    p0.Anchored, p0.CanCollide, p0.Transparency = true, false, 1
    p0.Size = Vector3.new(0.1, 0.1, 0.1)
    p0.CanQuery, p0.CanTouch = false, false
    local p1 = Instance.new("Part", WS)
    p1.Anchored, p1.CanCollide, p1.Transparency = true, false, 1
    p1.Size = Vector3.new(0.1, 0.1, 0.1)
    p1.CanQuery, p1.CanTouch = false, false
    local a0 = Instance.new("Attachment", p0)
    local a1 = Instance.new("Attachment", p1)
    local beam = Instance.new("Beam", WS)
    beam.Texture = TRACE_TEXTURE
    beam.TextureMode = Enum.TextureMode.Wrap
    beam.TextureLength = 2
    beam.TextureSpeed = 4
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    beam.LightEmission = 1
    beam.LightInfluence = 0
    beam.FaceCamera = true
    beam.Width0 = 3
    beam.Width1 = 3
    beam.Segments = 10
    beam.Attachment0 = a0
    beam.Attachment1 = a1
    local conn = RS.RenderStepped:Connect(function()
        local curName = S.traceTarget
        if not onFlag() or not curName or not Players:FindFirstChild(curName) then
            if beam then beam:Destroy() end
            if p0 then p0:Destroy() end
            if p1 then p1:Destroy() end
            return
        end
        local curT = Players:FindFirstChild(curName)
        local my = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        local th = curT and curT.Character and curT.Character:FindFirstChild("HumanoidRootPart")
        if my and th then
            p0.Position = my.Position
            p1.Position = th.Position
        end
    end)
    return conn, beam
end

local function isEspTarget(o)
    if not o:IsA("BasePart") then return false end
    for _, n in ipairs(ESP_TARGETS) do
        if string.lower(o.Name) == string.lower(n) then return true end
    end
    return false
end

local function addEsp(o)
    if S.espBoxes[o] then S.espBoxes[o].Color3 = S.espColor; return end
    local b = Instance.new("BoxHandleAdornment")
    b.Adornee = o
    b.AlwaysOnTop = true
    b.ZIndex = 5
    b.Color3 = S.espColor
    b.Transparency = 0.5
    b.Size = o.Size
    b.Parent = game.CoreGui
    S.espBoxes[o] = b
    o.AncestryChanged:Connect(function(_, p)
        if not p and S.espBoxes[o] then
            S.espBoxes[o]:Destroy()
            S.espBoxes[o] = nil
        end
    end)
end

local function clearEsp()
    for _, b in pairs(S.espBoxes) do if b then b:Destroy() end end
    S.espBoxes = {}
end

local function scanEsp()
    for _, o in ipairs(workspace:GetDescendants()) do
        if S.espOn and isEspTarget(o) then addEsp(o) end
    end
end

local function packetDetector()
    REP.GrabEvents.ExtendGrabLine.OnClientEvent:Connect(function(src, data)
        if typeof(data) == "string" and not S.pktCooldown and S.pktNotify then
            S.pktCooldown = true
            local len = string.len(data)
            if len > 300 then
                local mb = math.round(len / 1024 / 1024 * 1000) / 1000
                Library:Notify({Title = "Eris hub", Description = "PACKET LAG\nSource: " .. tostring(src):sub(1,20) .. "\nSize: " .. mb .. " MB", Duration = 5})
            end
            task.delay(5, function() S.pktCooldown = false end)
        end
    end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "ErisHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = pgui

local notifySound = Instance.new("Sound")
notifySound.SoundId = NOTIFY_SOUND
notifySound.Volume = 0.5
notifySound.Parent = SS

local notifyHolder = Instance.new("Frame", gui)
notifyHolder.Name = "Notif"
notifyHolder.Size = UDim2.new(0, 300, 1, 0)
notifyHolder.Position = UDim2.new(1, -320, 0, 20)
notifyHolder.BackgroundTransparency = 1
notifyHolder.ZIndex = 10000
local nlist = Instance.new("UIListLayout", notifyHolder)
nlist.Padding = UDim.new(0, 8)

local function corner(p, r) local c = Instance.new("UICorner", p); c.CornerRadius = UDim.new(0, r or 10); return c end
local function stroke(p, col, tr) local s = Instance.new("UIStroke", p); s.Color = col or ACCENT; s.Thickness = 1; s.Transparency = tr or 0.5; return s end
local function label(p, txt, sz, col, align)
    local l = Instance.new("TextLabel", p)
    l.BackgroundTransparency = 1
    l.Text = txt or ""
    l.TextColor3 = col or Color3.fromRGB(225,235,245)
    l.TextSize = sz or 15
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = align or Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.TextStrokeTransparency = 1
    return l
end

local Library = {}
function Library:Notify(opts)
    opts = opts or {}
    if not notifyHolder or not notifyHolder.Parent then return end
    pcall(function()
        local s = notifySound:Clone()
        s.Parent = SS
        s:Play()
        s.Ended:Connect(function() s:Destroy() end)
        task.delay(3, function() if s then s:Destroy() end end)
    end)
    local nf = Instance.new("Frame", notifyHolder)
    nf.Size = UDim2.new(1, 0, 0, 56)
    nf.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
    nf.BackgroundTransparency = 0.15
    nf.BorderSizePixel = 0
    nf.ZIndex = 10001
    corner(nf, 10)
    local ns = stroke(nf, ACCENT, 0.3)
    local tl = label(nf, opts.Title or "Eris hub", 14, ACCENT2)
    tl.Size = UDim2.new(1, -20, 0, 18)
    tl.Position = UDim2.new(0, 10, 0, 5)
    tl.ZIndex = 10002
    local dl = label(nf, opts.Description or "", 13, Color3.fromRGB(230,240,250))
    dl.Size = UDim2.new(1, -20, 0, 28)
    dl.Position = UDim2.new(0, 10, 0, 22)
    dl.TextWrapped = true
    dl.ZIndex = 10002
    task.delay(opts.Duration or 4, function()
        if not nf.Parent then return end
        local t = Tween:Create(nf, TweenInfo.new(0.3), {BackgroundTransparency = 1})
        t:Play()
        Tween:Create(tl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        Tween:Create(dl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        Tween:Create(ns, TweenInfo.new(0.3), {Transparency = 1}):Play()
        t.Completed:Connect(function() nf:Destroy() end)
    end)
end

local mainSize = IS_MOBILE and UDim2.new(0, 500, 0, 520) or UDim2.new(0, 720, 0, 720)

local main = Instance.new("Frame", gui)
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.Size = mainSize
main.BackgroundColor3 = DARK
main.BackgroundTransparency = 1
main.BorderSizePixel = 0
main.ClipsDescendants = true
corner(main, 20)
stroke(main, ACCENT, 0.35).ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local bg = Instance.new("ImageLabel", main)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundTransparency = 1
bg.Image = "rbxassetid://95080673394037"
bg.ScaleType = Enum.ScaleType.Crop
bg.ImageTransparency = 0.1
bg.ZIndex = 0
corner(bg, 20)

local bg2 = Instance.new("ImageLabel", main)
bg2.Size = UDim2.new(1, 0, 1, 0)
bg2.BackgroundTransparency = 1
bg2.Image = "rbxassetid://95080673394037"
bg2.ScaleType = Enum.ScaleType.Crop
bg2.ImageTransparency = 0.55
bg2.ZIndex = 1
corner(bg2, 20)

local dark = Instance.new("Frame", main)
dark.Size = UDim2.new(1, 0, 1, 0)
dark.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
dark.BackgroundTransparency = 0.45
dark.BorderSizePixel = 0
dark.ZIndex = 2
corner(dark, 20)

local TOPH = IS_MOBILE and 60 or 75

local top = Instance.new("Frame", main)
top.Size = UDim2.new(1, 0, 0, TOPH)
top.BackgroundColor3 = Color3.fromRGB(5, 7, 12)
top.BackgroundTransparency = 0.25
top.BorderSizePixel = 0
top.ZIndex = 3
corner(top, 20)

local title = label(top, "Eris hub", IS_MOBILE and 26 or 34, Color3.fromRGB(255,255,255))
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, IS_MOBILE and 14 or 20, 0, 0)
title.ZIndex = 4
local tg = Instance.new("UIGradient", title)
tg.Color = ColorSequence.new(ACCENT2, Color3.fromRGB(255,255,255))

local line = Instance.new("Frame", top)
line.Size = UDim2.new(1, 0, 0, 1)
line.Position = UDim2.new(0, 0, 1, -1)
line.BackgroundColor3 = ACCENT
line.BackgroundTransparency = 0.55
line.BorderSizePixel = 0
line.ZIndex = 4

if IS_MOBILE then
    local closeBtn = Instance.new("TextButton", top)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -38, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(0, 0.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 6
    corner(closeBtn, 8)
    stroke(closeBtn, Color3.fromRGB(255, 100, 100), 0.3)

    local hideBtn = Instance.new("TextButton", top)
    hideBtn.Size = UDim2.new(0, 30, 0, 30)
    hideBtn.Position = UDim2.new(1, -74, 0.5, 0)
    hideBtn.AnchorPoint = Vector2.new(0, 0.5)
    hideBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    hideBtn.Text = "—"
    hideBtn.TextColor3 = ACCENT2
    hideBtn.TextSize = 18
    hideBtn.Font = Enum.Font.GothamBold
    hideBtn.BorderSizePixel = 0
    hideBtn.ZIndex = 6
    corner(hideBtn, 8)
    stroke(hideBtn, ACCENT, 0.3)

    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
    hideBtn.MouseButton1Click:Connect(function() main.Visible = false end)
end

local SIDEBAR = IS_MOBILE and 140 or 190

local side = Instance.new("Frame", main)
side.Size = UDim2.new(0, SIDEBAR, 1, -TOPH)
side.Position = UDim2.new(0, 0, 0, TOPH)
side.BackgroundColor3 = Color3.fromRGB(5, 7, 12)
side.BackgroundTransparency = 0.35
side.BorderSizePixel = 0
side.ZIndex = 3

local div = Instance.new("Frame", side)
div.Size = UDim2.new(0, 1, 1, 0)
div.Position = UDim2.new(1, -1, 0, 0)
div.BackgroundColor3 = ACCENT
div.BackgroundTransparency = 0.5
div.BorderSizePixel = 0
div.ZIndex = 4

local sideScroll = Instance.new("ScrollingFrame", side)
sideScroll.Size = UDim2.new(1, 0, 1, 0)
sideScroll.BackgroundTransparency = 1
sideScroll.BorderSizePixel = 0
sideScroll.ScrollBarThickness = 3
sideScroll.ScrollBarImageColor3 = ACCENT
sideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
sideScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
sideScroll.ZIndex = 4
local sl = Instance.new("UIListLayout", sideScroll)
sl.Padding = UDim.new(0, IS_MOBILE and 5 or 8)
sl.SortOrder = Enum.SortOrder.LayoutOrder
local sp = Instance.new("UIPadding", sideScroll)
sp.PaddingTop = UDim.new(0, IS_MOBILE and 8 or 12)
sp.PaddingLeft = UDim.new(0, IS_MOBILE and 8 or 12)
sp.PaddingRight = UDim.new(0, IS_MOBILE and 8 or 12)
sp.PaddingBottom = UDim.new(0, IS_MOBILE and 8 or 12)

local wrapper = Instance.new("Frame", main)
wrapper.Size = UDim2.new(1, -SIDEBAR, 1, -TOPH)
wrapper.Position = UDim2.new(0, SIDEBAR, 0, TOPH)
wrapper.BackgroundTransparency = 1
wrapper.ZIndex = 2

local content = Instance.new("Frame", wrapper)
content.Size = UDim2.new(0.94, 0, 1, 0)
content.Position = UDim2.new(0.5, 0, 0, 0)
content.AnchorPoint = Vector2.new(0.5, 0)
content.BackgroundTransparency = 1
content.ZIndex = 2
local cp = Instance.new("UIPadding", content)
cp.PaddingTop = UDim.new(0, 10); cp.PaddingLeft = UDim.new(0, 8)
cp.PaddingRight = UDim.new(0, 8); cp.PaddingBottom = UDim.new(0, 10)

local pages, sections, currentPage = {}, {}, nil

local function closeAllDropdowns()
    for _, fn in ipairs(S.openDropdowns) do pcall(fn) end
end

local function showPage(name)
    currentPage = name
    closeAllDropdowns()
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, b in pairs(sections) do
        local active = n == name
        Tween:Create(b, TweenInfo.new(0.15), {
            BackgroundTransparency = active and 0.1 or 0.35,
            BackgroundColor3 = active and Color3.fromRGB(0, 90, 130) or Color3.fromRGB(22, 28, 38)
        }):Play()
        local st = b:FindFirstChildOfClass("UIStroke")
        if st then Tween:Create(st, TweenInfo.new(0.15), {Transparency = active and 0 or 0.55}):Play() end
        local l = b:FindFirstChild("Label")
        if l then l.TextColor3 = active and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,215,230) end
    end
end

local function createPage(name)
    local p = Instance.new("ScrollingFrame", content)
    p.Name = name
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = ACCENT
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.Visible = false
    p.ZIndex = 2
    local lay = Instance.new("UIListLayout", p)
    lay.Padding = UDim.new(0, 6)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    pages[name] = p
    return p
end

local SMALL_H = 26
local SMALL_FONT = 12

-- возвращаем "контейнер" но без квадрата: просто фрейм-обёртка с заголовком
local function makeGroup(p, title, order)
    local wrap = Instance.new("Frame", p)
    wrap.Name = title .. "Wrap"
    wrap.Size = UDim2.new(1, 0, 0, 30)
    wrap.BackgroundTransparency = 1
    wrap.BorderSizePixel = 0
    wrap.ZIndex = 3
    wrap.LayoutOrder = order

    local h = label(wrap, title, 14, ACCENT2)
    h.Size = UDim2.new(1, -12, 0, 20)
    h.Position = UDim2.new(0, 4, 0, 0)
    h.ZIndex = 4

    local inner = Instance.new("Frame", wrap)
    inner.Name = "Inner"
    inner.BackgroundTransparency = 1
    inner.Position = UDim2.new(0, 0, 0, 24)
    inner.Size = UDim2.new(1, 0, 0, 0)
    inner.ZIndex = 4
    local lay = Instance.new("UIListLayout", inner)
    lay.Padding = UDim.new(0, 4)
    lay.SortOrder = Enum.SortOrder.LayoutOrder

    local function fit()
        local contentY = lay.AbsoluteContentSize.Y
        inner.Size = UDim2.new(1, 0, 0, contentY)
        local total = contentY + 28
        if total < 40 then total = 40 end
        wrap.Size = UDim2.new(1, 0, 0, total)
    end

    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fit)
    task.spawn(function()
        for i = 1, 15 do
            fit()
            RS.RenderStepped:Wait()
        end
    end)

    return inner
end

local function makeSmallToggle(p, txt, def, cb, order)
    local row = Instance.new("Frame", p)
    row.Size = UDim2.new(1, 0, 0, SMALL_H)
    row.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.ZIndex = 3
    corner(row, 6)

    local pad = Instance.new("UIPadding", row)
    pad.PaddingLeft = UDim.new(0, 8); pad.PaddingRight = UDim.new(0, 8)
    local l = label(row, txt, SMALL_FONT)
    l.Size = UDim2.new(1, -40, 1, 0)
    l.ZIndex = 4
    local tr = Instance.new("Frame", row)
    tr.Size = UDim2.new(0, 28, 0, 14)
    tr.Position = UDim2.new(1, -28, 0.5, 0)
    tr.AnchorPoint = Vector2.new(0, 0.5)
    tr.BackgroundColor3 = Color3.fromRGB(40, 50, 65)
    tr.BorderSizePixel = 0
    tr.ZIndex = 4
    corner(tr, 999)
    local k = Instance.new("Frame", tr)
    k.Size = UDim2.new(0, 10, 0, 10)
    k.Position = UDim2.new(0, 2, 0.5, 0)
    k.AnchorPoint = Vector2.new(0, 0.5)
    k.BackgroundColor3 = Color3.fromRGB(220, 230, 240)
    k.BorderSizePixel = 0
    k.ZIndex = 5
    corner(k, 999)
    local state = def or false
    local function apply(anim)
        local pos = state and UDim2.new(1, -12, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        local col = state and ACCENT or Color3.fromRGB(40, 50, 65)
        if anim then
            Tween:Create(k, TweenInfo.new(0.15), {Position = pos}):Play()
            Tween:Create(tr, TweenInfo.new(0.15), {BackgroundColor3 = col}):Play()
        else k.Position = pos; tr.BackgroundColor3 = col end
    end
    apply(false)
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 6
    btn.MouseButton1Click:Connect(function()
        state = not state
        apply(true)
        if cb then pcall(cb, state) end
    end)
    return {set = function(v) state = v; apply(true); if cb then pcall(cb, state) end end}
end

local function makeSmallButton(p, txt, fn, order)
    local row = Instance.new("Frame", p)
    row.Size = UDim2.new(1, 0, 0, SMALL_H)
    row.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.ZIndex = 3
    corner(row, 6)

    local b = Instance.new("TextButton", row)
    b.Size = UDim2.new(1, -10, 0, 20)
    b.Position = UDim2.new(0, 5, 0.5, 0)
    b.AnchorPoint = Vector2.new(0, 0.5)
    b.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
    b.BackgroundTransparency = 0.2
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(225,235,245)
    b.TextSize = SMALL_FONT
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.ZIndex = 4
    b.TextStrokeTransparency = 1
    corner(b, 5)
    b.MouseEnter:Connect(function() Tween:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 90, 130)}):Play() end)
    b.MouseLeave:Connect(function() Tween:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 40, 55)}):Play() end)
    b.MouseButton1Click:Connect(function() if fn then pcall(fn) end end)
    return b
end

local function makeSmallSlider(p, txt, mn, mx, def, cb, order)
    local row = Instance.new("Frame", p)
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.ZIndex = 3
    corner(row, 6)

    local pad = Instance.new("UIPadding", row)
    pad.PaddingLeft = UDim.new(0, 8); pad.PaddingRight = UDim.new(0, 8)
    pad.PaddingTop = UDim.new(0, 4); pad.PaddingBottom = UDim.new(0, 4)
    local l = label(row, txt, SMALL_FONT)
    l.Size = UDim2.new(1, -36, 0, 14)
    l.ZIndex = 4
    local vl = label(row, tostring(def), SMALL_FONT, ACCENT, Enum.TextXAlignment.Right)
    vl.Size = UDim2.new(0, 36, 0, 14)
    vl.Position = UDim2.new(1, -36, 0, 0)
    vl.ZIndex = 4
    local bar = Instance.new("Frame", row)
    bar.Size = UDim2.new(1, 0, 0, 5)
    bar.Position = UDim2.new(0, 0, 1, -9)
    bar.AnchorPoint = Vector2.new(0, 0.5)
    bar.BackgroundColor3 = Color3.fromRGB(40, 50, 65)
    bar.BorderSizePixel = 0
    bar.ZIndex = 4
    corner(bar, 999)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = ACCENT
    fill.BorderSizePixel = 0
    fill.ZIndex = 5
    corner(fill, 999)
    local k = Instance.new("Frame", bar)
    k.Size = UDim2.new(0, 10, 0, 10)
    k.AnchorPoint = Vector2.new(0.5, 0.5)
    k.Position = UDim2.new(0.5, 0, 0.5, 0)
    k.BackgroundColor3 = Color3.fromRGB(255,255,255)
    k.BorderSizePixel = 0
    k.ZIndex = 6
    corner(k, 999)
    local val, drag = def, false
    local function set(x)
        local r = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        val = mn + (mx - mn) * r
        val = (mx - mn > 20) and math.floor(val + 0.5) or math.floor(val * 100 + 0.5) / 100
        fill.Size = UDim2.new(r, 0, 1, 0)
        k.Position = UDim2.new(r, 0, 0.5, 0)
        vl.Text = tostring(val)
        if cb then pcall(cb, val) end
    end
    do
        local r = math.clamp((def - mn) / (mx - mn), 0, 1)
        fill.Size = UDim2.new(r, 0, 1, 0)
        k.Position = UDim2.new(r, 0, 0.5, 0)
    end
    local hit = Instance.new("TextButton", row)
    hit.Size = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.ZIndex = 7
    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; set(i.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            set(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
    return {set = function(v) val = v; if cb then pcall(cb, v) end end}
end

local function makeSmallDropdown(p, txt, values, def, cb, order)
    local row = Instance.new("Frame", p)
    row.Size = UDim2.new(1, 0, 0, SMALL_H)
    row.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.ZIndex = 3
    corner(row, 6)

    local pad = Instance.new("UIPadding", row)
    pad.PaddingLeft = UDim.new(0, 8); pad.PaddingRight = UDim.new(0, 8)
    local l = label(row, txt, SMALL_FONT)
    l.Size = UDim2.new(1, -100, 1, 0)
    l.ZIndex = 4
    local vl = label(row, def or "None", SMALL_FONT, ACCENT2, Enum.TextXAlignment.Right)
    vl.Size = UDim2.new(0, 90, 1, 0)
    vl.Position = UDim2.new(1, -90, 0, 0)
    vl.ZIndex = 4

    local dg = Instance.new("ScreenGui")
    dg.Name = "ErisDropdownGui"
    dg.ResetOnSpawn = false
    dg.IgnoreGuiInset = true
    dg.DisplayOrder = 100000
    dg.Enabled = false
    dg.Parent = pgui

    local pop = Instance.new("Frame", dg)
    pop.Size = UDim2.new(0, 200, 0, 100)
    pop.BackgroundColor3 = Color3.fromRGB(15, 20, 28)
    pop.BorderSizePixel = 0
    corner(pop, 6)
    stroke(pop, ACCENT, 0.3)

    local sc = Instance.new("ScrollingFrame", pop)
    sc.Size = UDim2.new(1, -6, 1, -6)
    sc.Position = UDim2.new(0, 3, 0, 3)
    sc.BackgroundTransparency = 1
    sc.BorderSizePixel = 0
    sc.ScrollBarThickness = 2
    sc.ScrollBarImageColor3 = ACCENT
    sc.CanvasSize = UDim2.new(0, 0, 0, 0)
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local pl = Instance.new("UIListLayout", sc)
    pl.Padding = UDim.new(0, 3)

    local cur = def
    local function refresh()
        for _, c in ipairs(sc:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, v in ipairs(values) do
            local b = Instance.new("TextButton", sc)
            b.Size = UDim2.new(1, 0, 0, 24)
            b.BackgroundColor3 = Color3.fromRGB(25, 32, 44)
            b.BackgroundTransparency = 0.3
            b.Text = v
            b.TextColor3 = Color3.fromRGB(220, 230, 240)
            b.TextSize = 13
            b.Font = Enum.Font.GothamBold
            b.BorderSizePixel = 0
            b.TextStrokeTransparency = 1
            b.TextXAlignment = Enum.TextXAlignment.Left
            corner(b, 4)
            local bpad = Instance.new("UIPadding", b)
            bpad.PaddingLeft = UDim.new(0, 8)
            b.MouseEnter:Connect(function() Tween:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 90, 130), BackgroundTransparency = 0}):Play() end)
            b.MouseLeave:Connect(function() Tween:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25, 32, 44), BackgroundTransparency = 0.3}):Play() end)
            b.MouseButton1Click:Connect(function()
                cur = v
                vl.Text = v
                dg.Enabled = false
                if cb then pcall(cb, v) end
            end)
        end
        pop.Size = UDim2.new(0, 200, 0, math.min(#values, 6) * 28 + 10)
    end
    refresh()

    local closeFn = function() dg.Enabled = false end
    table.insert(S.openDropdowns, closeFn)

    local open = Instance.new("TextButton", row)
    open.Size = UDim2.new(1, 0, 1, 0)
    open.BackgroundTransparency = 1
    open.Text = ""
    open.ZIndex = 5
    open.MouseButton1Click:Connect(function()
        closeAllDropdowns()
        dg.Enabled = not dg.Enabled
        if dg.Enabled then
            pop.Position = UDim2.new(0, row.AbsolutePosition.X, 0, row.AbsolutePosition.Y + row.AbsoluteSize.Y + 3)
        end
    end)

    UIS.InputBegan:Connect(function(i, gp)
        if gp or not dg.Enabled then return end
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            local mp = UIS:GetMouseLocation()
            local pp, ps = pop.AbsolutePosition, pop.AbsoluteSize
            local rp, rs = row.AbsolutePosition, row.AbsoluteSize
            local inPop = mp.X >= pp.X and mp.X <= pp.X + ps.X and mp.Y >= pp.Y and mp.Y <= pp.Y + ps.Y
            local inRow = mp.X >= rp.X and mp.X <= rp.X + rs.X and mp.Y >= rp.Y and mp.Y <= rp.Y + rs.Y
            if not inPop and not inRow then dg.Enabled = false end
        end
    end)

    return {
        set = function(v) cur = v; vl.Text = v or "None"; if cb then pcall(cb, v) end end,
        setValues = function(nv) values = nv; refresh() end,
        get = function() return cur end,
    }
end

local function createSection(name, icon, order)
    local b = Instance.new("TextButton", sideScroll)
    b.Name = name .. "Btn"
    b.Size = UDim2.new(1, 0, 0, IS_MOBILE and 40 or 48)
    b.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    b.BackgroundTransparency = 0.35
    b.BorderSizePixel = 0
    b.Text = ""
    b.AutoButtonColor = false
    b.ZIndex = 4
    b.LayoutOrder = order
    corner(b, 10)
    stroke(b, ACCENT, 0.55).ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local ic = Instance.new("Frame", b)
    ic.Size = UDim2.new(0, IS_MOBILE and 26 or 30, 0, IS_MOBILE and 26 or 30)
    ic.Position = UDim2.new(0, 8, 0.5, 0)
    ic.AnchorPoint = Vector2.new(0, 0.5)
    ic.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
    ic.BackgroundTransparency = 0.2
    ic.BorderSizePixel = 0
    ic.ZIndex = 5
    corner(ic, 8)
    stroke(ic, ACCENT, 0.4).ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local im = Instance.new("ImageLabel", ic)
    im.Size = UDim2.new(1, -8, 1, -8)
    im.Position = UDim2.new(0.5, 0, 0.5, 0)
    im.AnchorPoint = Vector2.new(0.5, 0.5)
    im.BackgroundTransparency = 1
    im.Image = "rbxassetid://" .. tostring(icon)
    im.ZIndex = 6

    local l = label(b, name, IS_MOBILE and 13 or 15, Color3.fromRGB(200, 215, 230))
    l.Name = "Label"
    l.Size = UDim2.new(1, -50, 1, 0)
    l.Position = UDim2.new(0, IS_MOBILE and 40 or 46, 0, 0)
    l.ZIndex = 5

    b.MouseEnter:Connect(function()
        if currentPage == name then return end
        Tween:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 0.15, BackgroundColor3 = Color3.fromRGB(30, 40, 55)}):Play()
    end)
    b.MouseLeave:Connect(function()
        if currentPage == name then return end
        Tween:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 0.35, BackgroundColor3 = Color3.fromRGB(22, 28, 38)}):Play()
    end)
    b.MouseButton1Click:Connect(function() showPage(name) end)
    sections[name] = b
    createPage(name)
end

createSection("home", 11347112400, 1)
createSection("player", 7992557358, 2)
createSection("target", 139650104834071, 3)
createSection("blobman", 80038693012109, 4)
createSection("visual", 16369898431, 5)
createSection("server", 9692125126, 6)
createSection("fun", 15290394895, 7)
createSection("keybind", 121332782788896, 8)
createSection("settings", 9405931578, 9)

-- HOME (собран компактно, друг за другом)
do
    local p = pages["home"]
    p.UIListLayout.Padding = UDim.new(0, 6)

    -- 1. Welcome
    local welcome = label(p, "Welcome to Eris Hub", 22, Color3.fromRGB(255,255,255))
    welcome.Size = UDim2.new(1, 0, 0, 30)
    welcome.LayoutOrder = 1
    local wg = Instance.new("UIGradient", welcome)
    wg.Color = ColorSequence.new(ACCENT2, Color3.fromRGB(255,255,255))

    -- 2. Текст с пожеланиями (чуть больше)
    local text = Instance.new("TextLabel", p)
    text.Size = UDim2.new(1, 0, 0, 130)
    text.BackgroundTransparency = 1
    text.Text = "Thank you for launching my script; I hope it lives up to its price and your expectations. Our Discord server is — join. Wishing you a great mood and an enjoyable game with my script. By Marlin."
    text.TextColor3 = Color3.fromRGB(215, 225, 235)
    text.TextSize = 16
    text.Font = Enum.Font.GothamBold
    text.TextWrapped = true
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Top
    text.TextStrokeTransparency = 1
    text.ZIndex = 3
    text.LayoutOrder = 2

    -- 3. Join кнопка сразу после текста
    local joinBtn = Instance.new("TextButton", p)
    joinBtn.Size = UDim2.new(0, 100, 0, 28)
    joinBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    joinBtn.Text = "Join"
    joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    joinBtn.TextSize = 14
    joinBtn.Font = Enum.Font.GothamBold
    joinBtn.BorderSizePixel = 0
    joinBtn.AutoButtonColor = false
    joinBtn.ZIndex = 4
    joinBtn.LayoutOrder = 3
    corner(joinBtn, 6)
    joinBtn.TextStrokeTransparency = 1
    joinBtn.MouseEnter:Connect(function() Tween:Create(joinBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(110, 120, 250)}):Play() end)
    joinBtn.MouseLeave:Connect(function() Tween:Create(joinBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play() end)
    joinBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then setclipboard(DISCORD_LINK) end
        end)
        Library:Notify({Title = "Eris hub", Description = "Discord link copied to clipboard!", Duration = 3})
    end)

    -- 4. Player Info header
    local infoHeader = label(p, "Player Info", 15, ACCENT2)
    infoHeader.Size = UDim2.new(1, 0, 0, 22)
    infoHeader.LayoutOrder = 4

    -- 5. Инфо фрейм
    local infoFrame = Instance.new("Frame", p)
    infoFrame.Size = UDim2.new(1, 0, 0, 130)
    infoFrame.BackgroundColor3 = Color3.fromRGB(8, 12, 18)
    infoFrame.BackgroundTransparency = 0.35
    infoFrame.BorderSizePixel = 0
    infoFrame.LayoutOrder = 5
    corner(infoFrame, 10)

    local infoList = Instance.new("UIListLayout", infoFrame)
    infoList.Padding = UDim.new(0, 4)
    infoList.SortOrder = Enum.SortOrder.LayoutOrder
    local infoPad = Instance.new("UIPadding", infoFrame)
    infoPad.PaddingTop = UDim.new(0, 8)
    infoPad.PaddingLeft = UDim.new(0, 10)
    infoPad.PaddingRight = UDim.new(0, 10)
    infoPad.PaddingBottom = UDim.new(0, 8)

    local function makeInfoRow(txt, order)
        local l = label(infoFrame, txt, 13, Color3.fromRGB(220, 230, 240))
        l.Size = UDim2.new(1, 0, 0, 20)
        l.LayoutOrder = order
        l.ZIndex = 4
        return l
    end

    makeInfoRow("Display Name:  " .. plr.DisplayName, 1)
    makeInfoRow("Username:  @" .. plr.Name, 2)
    makeInfoRow("Account created:  " .. getAccountDate() .. " (" .. getAccountAge() .. " ago)", 3)
    makeInfoRow("Executor:  " .. EXECUTOR_NAME, 4)

    local uptimeRow = makeInfoRow("Script uptime:  00:00:00", 5)
    task.spawn(function()
        while uptimeRow.Parent do
            local s = math.floor(os.clock() - START_TIME)
            uptimeRow.Text = string.format("Script uptime:  %02d:%02d:%02d", math.floor(s/3600), math.floor(s%3600/60), s%60)
            RS.RenderStepped:Wait()
        end
    end)
end

-- PLAYER
do
    local p = pages["player"]
    local defScroll = makeGroup(p, "Defence", 1)

    makeSmallToggle(defScroll, "Anti Ownership", false, function(v)
        S.antiOwn = v
        if v then S.antiOwnTask = task.spawn(antiOwnershipLoop)
        else
            if S.antiOwnTask then pcall(task.cancel, S.antiOwnTask); S.antiOwnTask = nil end
            local c = plr.Character
            if c then for _, x in ipairs(c:GetChildren()) do if x:IsA("BasePart") then x.Anchored = false end end end
        end
    end, 1)

    makeSmallToggle(defScroll, "Anti Grab", false, function(v)
        if v then
            local c = plr.Character or plr.CharacterAdded:Wait()
            local h, hum, hd = FWC(c, "HumanoidRootPart"), FWC(c, "Humanoid"), FWC(c, "Head")
            if not (h and hum and hd) then return end
            S.agConns.head = hd.ChildAdded:Connect(function(po)
                if po.Name == "PartOwner" and not S.agProc then
                    S.agProc = true
                    hum.Sit = false
                    REP.CharacterEvents.Struggle:FireServer(plr)
                    task.spawn(function()
                        while hd:FindFirstChild("PartOwner") or (plr.IsHeld and plr.IsHeld.Value) do
                            REP.CharacterEvents.Struggle:FireServer(plr)
                            REP.CharacterEvents.RagdollRemote:FireServer(h, 0)
                            task.wait()
                        end
                    end)
                    h.Anchored = true
                    if not S.agWalk then
                        S.agWalk = true
                        while plr.IsHeld and plr.IsHeld.Value and task.wait() do
                            h.CFrame = h.CFrame + hum.MoveDirection * 0.43
                        end
                    end
                    h.Anchored = false
                    S.agProc, S.agWalk = false, false
                end
            end)
        else discAG("head") end
    end, 2)

    makeSmallToggle(defScroll, "Anti Ownership 2", false, function(v)
        if v then
            local held = plr:WaitForChild("IsHeld", 5)
            if not held then return end
            local st = REP:WaitForChild("CharacterEvents"):WaitForChild("Struggle")
            local saved
            S.agConns.own2 = held.Changed:Connect(function(h)
                local c = plr.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if h then
                    if hrp then saved = hrp.CFrame; hrp.Anchored = true end
                    task.spawn(function()
                        while held and held.Value do st:FireServer(plr); task.wait() end
                        if hrp and hrp.Parent then hrp.Anchored = false; if saved then hrp.CFrame = saved end end
                    end)
                else
                    if hrp and hrp.Parent then hrp.Anchored = false; if saved then hrp.CFrame = saved end end
                end
            end)
        else
            discAG("own2")
            local c = plr.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Anchored = false end
        end
    end, 3)

    makeSmallToggle(defScroll, "GO to home", false, function(v)
        if v then
            local Plot
            for _, plot in pairs(WS.Plots:GetChildren()) do
                if plot:FindFirstChild(plr.Name) then Plot = plot; break end
            end
            local Tppos = Vector3.new(252, -7, 464)
            if Plot then
                if Plot.Name == "Plot1" then Tppos = Vector3.new(-533, -7, 90)
                elseif Plot.Name == "Plot2" then Tppos = Vector3.new(-483, -7, -164)
                elseif Plot.Name == "Plot3" then Tppos = Vector3.new(252, -7, 464)
                elseif Plot.Name == "Plot4" then Tppos = Vector3.new(509, 83, -339)
                else Tppos = Vector3.new(553, 123, -74) end
            end
            local function setup(char)
                local hrp = FWC(char, "HumanoidRootPart")
                local hum = FWC(char, "Humanoid")
                task.spawn(function()
                    while true do
                        task.wait()
                        if not (plr.InPlot and plr.InPlot.Value) and hum.Health ~= 0 then
                            hrp.CFrame = CFrame.new(Tppos)
                            hrp.Anchored = false
                        end
                    end
                end)
            end
            setup(plr.Character or plr.CharacterAdded:Wait())
        end
    end, 4)

    makeSmallToggle(defScroll, "Anti Barrier", false, function(v)
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return end
        for _, plot in ipairs(plots:GetChildren()) do
            local b = plot:FindFirstChild("Barrier")
            if b then
                for _, pt in ipairs(b:GetChildren()) do
                    if pt:IsA("BasePart") and pt.Name == "PlotBarrier" then pt.CanCollide = not v end
                end
            end
        end
    end, 5)

    makeSmallToggle(defScroll, "Anti Paint", false, function(v)
        if v then
            for _, o in ipairs(workspace:GetDescendants()) do
                if o:IsA("BasePart") and o.Name == "PaintPlayerPart" then o:Destroy() end
            end
        end
        local c = workspace:FindFirstChild(plr.Name)
        if c then
            for _, x in ipairs(c:GetChildren()) do
                if x:IsA("BasePart") then x.CanTouch = not v; x.CanQuery = not v end
            end
        end
    end, 6)

    makeSmallButton(defScroll, "Delete Legs", deleteLegs, 7)

    makeSmallToggle(defScroll, "Shuriken Anti Kick", false, function(v)
        _G.ShurikenAntiKick = v
        if v then task.spawn(shurikenLoop) end
    end, 8)

    makeSmallToggle(defScroll, "Anti Lag", false, function(v)
        local ps = plr:WaitForChild("PlayerScripts")
        local s = ps:WaitForChild("CharacterAndBeamMove")
        if v then
            pcall(function() s.Disabled = true end)
            for _, o in ipairs(workspace:GetDescendants()) do
                if o:IsA("Beam") or o.Name:lower():find("line") then pcall(function() o:Destroy() end) end
            end
        else pcall(function() s.Disabled = false end) end
    end, 9)
end

-- TARGET
do
    local p = pages["target"]

    local selScroll = makeGroup(p, "Target Selection", 1)
    local list = playerList()
    local dd
    dd = makeSmallDropdown(selScroll, "Player", list, list[1], function(v)
        local pl = findPlayerByDisplay(v)
        S.target = pl and pl.Name or v
        if S.traceOn then
            if S.traceConn then S.traceConn:Disconnect(); S.traceConn = nil end
            if S.traceBeam then S.traceBeam:Destroy(); S.traceBeam = nil end
            S.traceTarget = S.target
            if S.target and S.target ~= "" then
                S.traceConn, S.traceBeam = startTraceFor(S.target, function() return S.traceOn end)
            end
        end
    end, 1)
    if list[1] then
        local pl = findPlayerByDisplay(list[1])
        S.target = pl and pl.Name or list[1]
    end
    makeSmallButton(selScroll, "Refresh List", function()
        local nl = playerList()
        dd.setValues(nl)
        if #nl > 0 and (not S.target or not Players:FindFirstChild(S.target)) then
            dd.set(nl[1])
            local pl = findPlayerByDisplay(nl[1])
            S.target = pl and pl.Name or nl[1]
        end
    end, 2)
    Players.PlayerAdded:Connect(function() task.wait(0.5); dd.setValues(playerList()) end)
    Players.PlayerRemoving:Connect(function(p2)
        if p2.Name == S.target then
            S.target = nil
            if S.traceOn then
                S.traceOn = false
                if S.traceConn then S.traceConn:Disconnect(); S.traceConn = nil end
                if S.traceBeam then S.traceBeam:Destroy(); S.traceBeam = nil end
            end
        end
        task.wait(0.5); dd.setValues(playerList())
    end)

    local extraScroll = makeGroup(p, "Extra", 2)
    makeSmallToggle(extraScroll, "Destroy Gucci", false, function(v)
        S.destroyGucci = v
        if v then S.destroyGucciTask = task.spawn(destroyGucciLoop)
        else if S.destroyGucciTask then pcall(task.cancel, S.destroyGucciTask); S.destroyGucciTask = nil end end
    end, 1)
    makeSmallToggle(extraScroll, "Remove All Anti Input", false, function(v)
        S.antiInput = v
        if v then S.antiInputTask = task.spawn(removeAntiInputLoop)
        else if S.antiInputTask then pcall(task.cancel, S.antiInputTask); S.antiInputTask = nil end end
    end, 2)
    makeSmallToggle(extraScroll, "Leave/Join Notify", false, function(v)
        if v then
            local tn = S.target
            if not tn or tn == "" then return end
            local t = Players:FindFirstChild(tn)
            if t then Library:Notify({Title = "Eris hub", Description = t.DisplayName .. " is in game", Duration = 3}) end
            S.notifyConns.add = Players.PlayerAdded:Connect(function(x)
                if x.Name == S.target then Library:Notify({Title = "Eris hub", Description = x.DisplayName .. " joined", Duration = 3}) end
            end)
            S.notifyConns.rem = Players.PlayerRemoving:Connect(function(x)
                if x.Name == S.target then Library:Notify({Title = "Eris hub", Description = x.DisplayName .. " left", Duration = 3}) end
            end)
        else
            for _, c in pairs(S.notifyConns) do if c then c:Disconnect() end end
            S.notifyConns = {}
        end
    end, 3)

    local kickScroll = makeGroup(p, "Kick Methods", 3)
    makeSmallToggle(kickScroll, "Ownership Kick", false, function(v)
        S.ownKick = v
        if v and S.target and S.target ~= "" then
            S.ownKickTask = task.spawn(function() ownershipKick(S.target) end)
        elseif v then S.ownKick = false
        else
            if S.ownKickTask then pcall(task.cancel, S.ownKickTask); S.ownKickTask = nil end
            local t = Players:FindFirstChild(S.target or "")
            if t and t.Character then
                local tr = t.Character:FindFirstChild("HumanoidRootPart")
                if tr then
                    for _, x in ipairs(tr:GetChildren()) do
                        if x:IsA("BodyPosition") or x:IsA("BodyGyro") then pcall(function() x:Destroy() end) end
                    end
                end
            end
        end
    end, 1)
    makeSmallToggle(kickScroll, "Pallet Ragdoll", false, function(v)
        S.ownRag = v
        if v and S.target and S.target ~= "" then
            S.ownRagTask = task.spawn(function() palletRagdoll(S.target) end)
        elseif v then S.ownRag = false
        else if S.ownRagTask then pcall(task.cancel, S.ownRagTask); S.ownRagTask = nil end end
    end, 2)

    local xzScroll = makeGroup(p, "XZ", 4)
    makeSmallToggle(xzScroll, "Loop Kill", false, function(v)
        S.loopKill = v
        if v and S.target and S.target ~= "" then
            S.loopKillTask = task.spawn(function() loopKill(S.target) end)
        elseif v then S.loopKill = false
        else if S.loopKillTask then pcall(task.cancel, S.loopKillTask); S.loopKillTask = nil end end
    end, 1)
    makeSmallToggle(xzScroll, "Snowball Ragdoll", false, function(v)
        S.snowball = v
        if v and S.target and S.target ~= "" then
            S.snowballTask = task.spawn(function() snowballRagdoll(S.target) end)
        elseif v then S.snowball = false
        else if S.snowballTask then pcall(task.cancel, S.snowballTask); S.snowballTask = nil end end
    end, 2)

    local traceScroll = makeGroup(p, "Trace", 5)
    makeSmallToggle(traceScroll, "Trace to Target", false, function(v)
        S.traceOn = v
        if v and S.target and S.target ~= "" then
            S.traceTarget = S.target
            S.traceConn, S.traceBeam = startTraceFor(S.target, function() return S.traceOn end)
        else
            S.traceOn = false
            if S.traceConn then S.traceConn:Disconnect(); S.traceConn = nil end
            if S.traceBeam then S.traceBeam:Destroy(); S.traceBeam = nil end
        end
    end, 1)
end

-- BLOBMAN
do
    local p = pages["blobman"]
    local blobTarget = nil
    local method = "Bring"

    local selScroll = makeGroup(p, "Target Selection", 1)
    local list = playerList()
    local dd
    dd = makeSmallDropdown(selScroll, "Player", list, list[1], function(v)
        local pl = findPlayerByDisplay(v)
        blobTarget = pl and pl.Name or v
    end, 1)
    if list[1] then
        local pl = findPlayerByDisplay(list[1])
        blobTarget = pl and pl.Name or list[1]
    end
    makeSmallButton(selScroll, "Refresh List", function()
        local nl = playerList()
        dd.setValues(nl)
        if #nl > 0 and (not blobTarget or not Players:FindFirstChild(blobTarget)) then
            dd.set(nl[1])
            local pl = findPlayerByDisplay(nl[1])
            blobTarget = pl and pl.Name or nl[1]
        end
    end, 2)
    Players.PlayerAdded:Connect(function() task.wait(0.5); dd.setValues(playerList()) end)
    Players.PlayerRemoving:Connect(function() task.wait(0.5); dd.setValues(playerList()) end)

    local extraScroll = makeGroup(p, "Extra", 2)
    makeSmallToggle(extraScroll, "Destroy Gucci", false, function(v)
        S.destroyGucci = v
        if v then S.destroyGucciTask = task.spawn(destroyGucciLoop)
        else if S.destroyGucciTask then pcall(task.cancel, S.destroyGucciTask); S.destroyGucciTask = nil end end
    end, 1)
    makeSmallToggle(extraScroll, "Remove All Anti Input", false, function(v)
        S.antiInput = v
        if v then S.antiInputTask = task.spawn(removeAntiInputLoop)
        else if S.antiInputTask then pcall(task.cancel, S.antiInputTask); S.antiInputTask = nil end end
    end, 2)
    makeSmallToggle(extraScroll, "Leave/Join Notify", false, function(v)
        if v then
            local tn = blobTarget
            if not tn or tn == "" then return end
            local t = Players:FindFirstChild(tn)
            if t then Library:Notify({Title = "Eris hub", Description = t.DisplayName .. " is in game", Duration = 3}) end
            S.notifyConns.blobAdd = Players.PlayerAdded:Connect(function(x)
                if x.Name == blobTarget then Library:Notify({Title = "Eris hub", Description = x.DisplayName .. " joined", Duration = 3}) end
            end)
            S.notifyConns.blobRem = Players.PlayerRemoving:Connect(function(x)
                if x.Name == blobTarget then Library:Notify({Title = "Eris hub", Description = x.DisplayName .. " left", Duration = 3}) end
            end)
        else
            if S.notifyConns.blobAdd then S.notifyConns.blobAdd:Disconnect(); S.notifyConns.blobAdd = nil end
            if S.notifyConns.blobRem then S.notifyConns.blobRem:Disconnect(); S.notifyConns.blobRem = nil end
        end
    end, 3)

    local featScroll = makeGroup(p, "Blobman Features", 3)
    makeSmallToggle(featScroll, "Remove Anti Kick", false, function(v)
        S.antiKick = v
        if v and blobTarget and blobTarget ~= "" then
            S.antiKickTask = task.spawn(function() removeAntiKick(blobTarget) end)
        elseif v then S.antiKick = false
        else if S.antiKickTask then pcall(task.cancel, S.antiKickTask); S.antiKickTask = nil end end
    end, 1)
    makeSmallToggle(featScroll, "Auto Sit Blobman", false, function(v)
        S.autoSit = v
        if v then
            task.spawn(function()
                while S.autoSit do
                    local c = plr.Character
                    local h = c and c:FindFirstChild("HumanoidRootPart")
                    local hum = c and c:FindFirstChild("Humanoid")
                    if not h or not hum or hum.SeatPart then task.wait(0.5); continue end
                    local folder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                    local blob = folder and folder:FindFirstChild("CreatureBlobman")
                    if not blob then
                        pcall(function()
                            REP.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", h.CFrame, Vector3.zero)
                        end)
                        folder = folder or workspace:WaitForChild(plr.Name .. "SpawnedInToys", 5)
                        blob = folder and folder:WaitForChild("CreatureBlobman", 5)
                    end
                    if blob then
                        local seat = blob:WaitForChild("VehicleSeat", 5)
                        if seat then
                            local t = tick()
                            repeat
                                if not hum.SeatPart then
                                    h.CFrame = seat.CFrame + Vector3.new(0, 1, 0)
                                    h.Velocity = Vector3.zero
                                    seat:Sit(hum)
                                end
                                RS.Heartbeat:Wait()
                            until hum.SeatPart == seat or tick() - t > 1.5 or not S.autoSit
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end, 2)

    local methDD = makeSmallDropdown(featScroll, "Selected Method",
        {"Bring", "Loop Kick", "Bypass", "Kick", "Loop Kick (Grab+Blob)", "Blob Kill", "Lock"},
        "Bring", function(v) method = v end, 3)
    local origSet = methDD.set
    methDD.set = function(v) method = v; origSet(v) end

    makeSmallButton(featScroll, "Apply Method Once", function()
        if not blobTarget or blobTarget == "" then return end
        if method == "Bring" then bringFunc(blobTarget)
        elseif method == "Kick" then kickFunc(blobTarget)
        elseif method == "Loop Kick" then loopKickFunc(blobTarget)
        elseif method == "Bypass" then bypassFunc(blobTarget)
        elseif method == "Loop Kick (Grab+Blob)" then S.loopKickBlob = true; task.spawn(function() loopKickBlob(blobTarget) end)
        elseif method == "Blob Kill" then task.spawn(function() blobKill(blobTarget) end)
        elseif method == "Lock" then BlobLock:Start(blobTarget)
        end
    end, 4)

    makeSmallButton(featScroll, "Destroy Visual", function()
        if blobTarget and blobTarget ~= "" then task.spawn(function() blobHeal(blobTarget) end) end
    end, 5)

    makeSmallToggle(featScroll, "Loop Apple Method", false, function(v)
        S.loopApple = v
        if v then
            if not blobTarget or blobTarget == "" then return end
            task.spawn(function()
                if method == "Loop Kick (Grab+Blob)" then
                    S.loopKickBlob = true
                    task.spawn(function() loopKickBlob(blobTarget) end)
                    while S.loopApple do task.wait(0.1) end
                    S.loopKickBlob = false
                elseif method == "Lock" then
                    BlobLock:Start(blobTarget)
                    while S.loopApple and BlobLock.Running do task.wait(0.1) end
                    BlobLock:Stop()
                else
                    while S.loopApple do
                        if method == "Bring" then bringFunc(blobTarget)
                        elseif method == "Kick" then kickFunc(blobTarget)
                        elseif method == "Loop Kick" then loopKickFunc(blobTarget)
                        elseif method == "Bypass" then bypassFunc(blobTarget)
                        elseif method == "Blob Kill" then task.spawn(function() blobKill(blobTarget) end)
                        end
                        task.wait(1)
                    end
                end
            end)
        else
            S.loopKickBlob = false
            BlobLock:Stop()
        end
    end, 6)

    local traceScroll = makeGroup(p, "Trace", 4)
    local bConn, bBeam = nil, nil
    makeSmallToggle(traceScroll, "Trace to Target", false, function(v)
        if v and blobTarget and blobTarget ~= "" then
            bConn, bBeam = startTraceFor(blobTarget, function() return bConn ~= nil end)
        else
            if bConn then bConn:Disconnect(); bConn = nil end
            if bBeam then bBeam:Destroy(); bBeam = nil end
        end
    end, 1)
end

-- VISUAL
do
    local p = pages["visual"]

    local camScroll = makeGroup(p, "Camera", 1)
    makeSmallSlider(camScroll, "Field of view", 30, 120, cam.FieldOfView, function(v)
        pcall(function() cam.FieldOfView = v end)
    end, 1)
    makeSmallToggle(camScroll, "Third person", false, function(v)
        if v then
            plr.CameraMode = Enum.CameraMode.Classic
            plr.CameraMaxZoomDistance = 1000
            plr.CameraMinZoomDistance = 0.5
        else
            plr.CameraMode = Enum.CameraMode.LockFirstPerson
            plr.CameraMaxZoomDistance = 0.5
            plr.CameraMinZoomDistance = 0.5
        end
    end, 2)

    local worldScroll = makeGroup(p, "World", 2)
    makeSmallSlider(worldScroll, "Time of day", 0, 24, math.floor(Lighting.ClockTime), function(v)
        pcall(function() Lighting.ClockTime = v end)
    end, 1)

    local espScroll = makeGroup(p, "ESP", 3)
    makeSmallToggle(espScroll, "PCLD ESP", false, function(v)
        S.espOn = v
        if v then
            workspace.DescendantAdded:Connect(function(o) if S.espOn and isEspTarget(o) then addEsp(o) end end)
            scanEsp()
        else clearEsp() end
    end, 1)

    local nameOn = false
    local nameTags = {}
    makeSmallToggle(espScroll, "Name ESP", false, function(v)
        nameOn = v
        local function make(p2)
            if p2 == plr or not p2.Character then return end
            local h = p2.Character:FindFirstChild("HumanoidRootPart")
            if not h or nameTags[p2] then return end
            local bb = Instance.new("BillboardGui", h)
            bb.Size = UDim2.new(0, 180, 0, 32)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            bb.Adornee = h
            local t = Instance.new("TextLabel", bb)
            t.Size = UDim2.new(1, 0, 1, 0)
            t.BackgroundTransparency = 1
            t.Text = p2.DisplayName
            t.TextColor3 = Color3.fromRGB(255,255,255)
            t.TextStrokeTransparency = 1
            t.TextSize = 14
            t.Font = Enum.Font.GothamBold
            nameTags[p2] = bb
        end
        if v then
            for _, p2 in ipairs(Players:GetPlayers()) do make(p2) end
            Players.PlayerAdded:Connect(function(p2)
                p2.CharacterAdded:Connect(function() task.wait(0.5); if nameOn then make(p2) end end)
            end)
        else
            for _, bb in pairs(nameTags) do pcall(function() bb:Destroy() end) end
            nameTags = {}
        end
    end, 2)

    local notifyScroll = makeGroup(p, "Notifications", 4)
    local kickConn
    makeSmallToggle(notifyScroll, "Kick Notify", false, function(v)
        if v then
            kickConn = workspace.ChildAdded:Connect(function(o)
                local names = {
                    blackholekick=true, ["blackholekicktweens(old)"]=true, blackholekicktweens=true,
                    jhole=true, blackhole=true, black_hole=true, voidhole=true, singularity=true,
                }
                if not o.Name or not names[o.Name:lower()] then return end
                task.wait(0.1)
                local pos
                if o:IsA("BasePart") then pos = o.Position
                else
                    local bp = o:FindFirstChildWhichIsA("BasePart", true)
                    if bp then pos = bp.Position end
                end
                if not pos then return end
                local c = closestPlayer(pos)
                if c and c ~= plr then Library:Notify({Title = "Eris hub", Description = c.DisplayName .. " got kicked!", Duration = 3})
                elseif c == plr then Library:Notify({Title = "Eris hub", Description = "You got kicked!", Duration = 3})
                else Library:Notify({Title = "Eris hub", Description = "Someone got kicked!", Duration = 3}) end
            end)
        else if kickConn then kickConn:Disconnect(); kickConn = nil end end
    end, 1)
    makeSmallToggle(notifyScroll, "Packet Lag Notify", false, function(v)
        S.pktNotify = v
        if v and not S.pktCooldown then pcall(packetDetector) end
    end, 2)
end

do end
do end
do end
do end

showPage("home")

local isOpen = true
local opened = {}
local function reg(o, prop, a, b) table.insert(opened, {o = o, p = prop, a = a, b = b}) end

reg(bg, "ImageTransparency", 0.1, 1)
reg(bg2, "ImageTransparency", 0.55, 1)
reg(dark, "BackgroundTransparency", 0.45, 1)
reg(top, "BackgroundTransparency", 0.25, 1)
reg(title, "TextTransparency", 0, 1)
reg(line, "BackgroundTransparency", 0.55, 1)
reg(side, "BackgroundTransparency", 0.35, 1)
reg(div, "BackgroundTransparency", 0.5, 1)
for _, b in pairs(sections) do
    reg(b, "BackgroundTransparency", 0.35, 1)
    local st = b:FindFirstChildOfClass("UIStroke")
    if st then reg(st, "Transparency", 0.55, 1) end
    local ic = b:FindFirstChild("Icon")
    if ic then
        reg(ic, "BackgroundTransparency", 0.2, 1)
        local is = ic:FindFirstChildOfClass("UIStroke")
        if is then reg(is, "Transparency", 0.4, 1) end
        local im = ic:FindFirstChildOfClass("ImageLabel")
        if im then reg(im, "ImageTransparency", 0, 1) end
    end
    local l = b:FindFirstChild("Label")
    if l then reg(l, "TextTransparency", 0, 1) end
end

local function setMenu(open)
    isOpen = open
    if not open then closeAllDropdowns() end
    local ti = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    if open then
        main.Visible = true
        main.Size = UDim2.new(0, IS_MOBILE and 420 or 560, 0, IS_MOBILE and 400 or 560)
        for _, i in ipairs(opened) do i.o[i.p] = i.b end
        Tween:Create(main, ti, {Size = mainSize}):Play()
        for _, i in ipairs(opened) do Tween:Create(i.o, ti, {[i.p] = i.a}):Play() end
    else
        local t = Tween:Create(main, ti, {Size = UDim2.new(0, IS_MOBILE and 420 or 560, 0, IS_MOBILE and 400 or 560)})
        t:Play()
        for _, i in ipairs(opened) do Tween:Create(i.o, ti, {[i.p] = i.b}):Play() end
        t.Completed:Connect(function() if not isOpen then main.Visible = false end end)
    end
end

main.Visible = false
task.wait(0.1)
setMenu(true)

if not IS_MOBILE then
    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.RightShift then setMenu(not isOpen) end
    end)
end

do
    local drag, startPos, startP
    top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag, startPos, startP = true, i.Position, main.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startPos
            main.Position = UDim2.new(startP.X.Scale, startP.X.Offset + d.X, startP.Y.Scale, startP.Y.Offset + d.Y)
        end
    end)
end