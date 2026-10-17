-- DUMMY HUB v5.5 | UI refaite + farm V4 + statistiques reelles
local P=game:GetService('Players').LocalPlayer
local UI=game:GetService('UserInputService')
local VU=game:GetService('VirtualUser')
local okVIM,VIM=pcall(function() return game:GetService('VirtualInputManager') end)
local PG=P:WaitForChild('PlayerGui')
local E=(type(getgenv)=='function' and getgenv()) or _G
for _,k in ipairs({'DummyHubStopV52','DummyHubStopV53','DummyHubStopV54','DummyHubStopV55'}) do
    if type(E[k])=='function' then pcall(E[k]) end
end
for _,n in ipairs({'DummyHubV5','DummyHubV52','DummyHubV53','DummyHubV54','DummyHubV55'}) do
    local g=PG:FindFirstChild(n); if g then g:Destroy() end
end

local K={bg=Color3.fromRGB(15,17,22),panel=Color3.fromRGB(23,26,33),
    side=Color3.fromRGB(19,21,27),line=Color3.fromRGB(49,54,65),
    ink=Color3.fromRGB(240,242,248),muted=Color3.fromRGB(151,160,178),
    blue=Color3.fromRGB(104,136,239),green=Color3.fromRGB(104,204,151),
    red=Color3.fromRGB(191,76,88)}
local function N(class,parent,props)
    local x=Instance.new(class)
    for k,v in pairs(props or {}) do x[k]=v end
    x.Parent=parent; return x
end
local function frame(parent,x,y,w,h,color,r)
    local f=N('Frame',parent,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
        BackgroundColor3=color or K.panel,BorderSizePixel=0})
    if r then N('UICorner',f,{CornerRadius=UDim.new(0,r)}) end
    return f
end
local function text(parent,s,x,y,w,h,size,color,bold)
    return N('TextLabel',parent,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
        BackgroundTransparency=1,Text=s,TextColor3=color or K.ink,
        TextSize=size or 12,Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
end
local function button(parent,s,x,y,w,h,color)
    local b=N('TextButton',parent,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
        BorderSizePixel=0,BackgroundColor3=color or K.panel,Text=s,
        TextSize=12,Font=Enum.Font.GothamMedium,TextColor3=K.ink,AutoButtonColor=true})
    N('UICorner',b,{CornerRadius=UDim.new(0,6)})
    return b
end
local function stroke(f)
    N('UIStroke',f,{Color=K.line,Thickness=1})
end
local function number(n)
    n=math.floor(n+0.5)
    local negative=n<0; local s=tostring(math.abs(n))
    s=s:reverse():gsub('(%d%d%d)','%1 '):reverse():gsub('^ ','')
    return (negative and '-' or '')..s
end
local function duration(s)
    return string.format('%02d:%02d:%02d',math.floor(s/3600),math.floor(s/60)%60,math.floor(s)%60)
end

-- Interface entierement redessinee
local gui=N('ScreenGui',PG,{Name='DummyHubV55',ResetOnSpawn=false,
    IgnoreGuiInset=true,DisplayOrder=99999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
local box=frame(gui,0,0,600,390,K.bg,10)
box.Position=UDim2.new(.5,-300,.5,-195); box.Active=true; box.ClipsDescendants=true
stroke(box)
local head=frame(box,0,0,600,48,K.side)
head.Active=true
frame(head,15,13,3,23,K.blue,2)
text(head,'DUMMY',28,11,90,25,16,K.ink,true)
text(head,'HUB',98,12,48,24,16,K.blue,true)
text(head,'v5.5',155,16,56,17,11,K.muted)
local headerState=text(head,'●  IDLE',416,17,90,18,11,K.muted,true)
local mini=button(head,'−',528,9,27,28)
local exit=button(head,'×',563,9,27,28)
frame(box,0,48,600,1,K.line)
local sidebar=frame(box,0,49,156,341,K.side)
text(sidebar,'WORKSPACE',17,19,130,20,10,K.muted,true)
local content=frame(box,174,59,409,316,K.bg)
content.BackgroundTransparency=1
local tabs,pages={},{}
local function show(name)
    for key,page in pairs(pages) do
        local active=key==name
        page.Visible=active
        tabs[key].BackgroundColor3=active and K.panel or K.side
        tabs[key].TextColor3=active and K.ink or K.muted
    end
end
for i,name in ipairs({'Farm','Tracker','Settings'}) do
    local tabName=name
    tabs[name]=button(sidebar,name,11,49+(i-1)*46,135,37,K.side)
    tabs[name].TextXAlignment=Enum.TextXAlignment.Left
    tabs[name].Text='   '..name
    pages[name]=frame(content,0,0,409,316,K.bg)
    pages[name].BackgroundTransparency=1
    pages[name].Visible=false
    tabs[name].MouseButton1Click:Connect(function() show(tabName) end)
end
frame(sidebar,14,317,7,7,K.green,4)
text(sidebar,'LIVE TRACKING',29,311,113,20,10,K.muted)
show('Farm')

local running,closed,antiAFK,id=false,false,true,0
local c,t,startC,startT=nil,nil,nil,nil
local timeSaved,started,forecast=0,nil,1000
local graphSamples,lastGraph= {},0
local function seconds()
    return timeSaved+(running and started and (os.clock()-started) or 0)
end
local function reset()
    if not c or not t then return end
    startC,startT=c.Value,t.Value
    timeSaved=0; started=running and os.clock() or nil
    forecast=1000; graphSamples={}; lastGraph=0
end
local function pause()
    if running and started then timeSaved=timeSaved+os.clock()-started end
    running=false; started=nil; id=id+1
    if not closed then headerState.Text='●  PAUSED'; headerState.TextColor3=K.muted end
end
local function waitRun(sec,version)
    local n=0
    while running and id==version and n<sec do
        n=n+task.wait(math.min(.1,sec-n))
    end
    return running and id==version
end
local function teleport(pos,angle)
    local ch=P.Character; local root=ch and ch:FindFirstChild('HumanoidRootPart')
    if not root then return false end
    root.CFrame=CFrame.new(pos)*CFrame.Angles(0,math.rad(angle),0)
    return true
end
local function attack()
    local ch=P.Character; if not ch then return end
    local tool=ch:FindFirstChildOfClass('Tool')
    if tool then pcall(function() tool:Activate() end) end
    pcall(function()
        local cam=workspace.CurrentCamera; if not cam then return end
        VU:CaptureController()
        VU:Button1Down(Vector2.new(0,0),cam.CFrame)
        task.wait(.15)
        VU:Button1Up(Vector2.new(0,0),cam.CFrame)
    end)
    if okVIM and VIM then pcall(function()
        local cam=workspace.CurrentCamera; if not cam then return end
        local v=cam.ViewportSize; local x,y=math.floor(v.X/2),math.floor(v.Y/2)
        VIM:SendMouseButtonEvent(x,y,0,true,game,0)
        task.wait(.15)
        VIM:SendMouseButtonEvent(x,y,0,false,game,0)
    end) end
end
local function start()
    if running or closed then return end
    if not c or not t then headerState.Text='●  LOADING'; return end
    if not startT then reset() end
    running=true; id=id+1; local version=id; started=os.clock()
    headerState.Text='●  FARMING'; headerState.TextColor3=K.green
    task.spawn(function()
        while running and id==version do
            local ch=P.Character; local hum=ch and ch:FindFirstChildOfClass('Humanoid')
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            for _,p in ipairs({{Vector3.new(66,441,-110),0},
                    {Vector3.new(243.81,440.89,-323.50),25}}) do
                if not running or id~=version then break end
                if teleport(p[1],p[2]) then
                    if not waitRun(1.5,version) then break end
                    attack()
                    if not waitRun(1.95,version) then break end
                elseif not waitRun(1,version) then break end
            end
        end
    end)
    task.spawn(function()
        while waitRun(300,version) do
            if antiAFK and okVIM and VIM then pcall(function()
                VIM:SendKeyEvent(true,Enum.KeyCode.Tab,false,game)
                task.wait(.1)
                VIM:SendKeyEvent(false,Enum.KeyCode.Tab,false,game)
            end) end
        end
    end)
end

-- Page Farm : bandeau, controles, informations
local farm=pages.Farm
text(farm,'Auto farm',0,3,260,28,21,K.ink,true)
text(farm,'Deux positions • attaques automatiques',0,33,398,21,12,K.muted)
local hero=frame(farm,0,66,409,88,K.panel,8); stroke(hero)
frame(hero,14,17,3,53,K.blue,2)
text(hero,'MODE',27,14,100,17,10,K.muted,true)
local farmText=text(hero,'Prêt à démarrer',27,36,337,28,18,K.ink,true)
local startBtn=button(farm,'▶  START FARM',0,173,197,43,Color3.fromRGB(39,109,79))
local stopBtn=button(farm,'■  STOP FARM',211,173,198,43,Color3.fromRGB(109,44,54))
startBtn.MouseButton1Click:Connect(function() start(); farmText.Text='Farm en cours' end)
stopBtn.MouseButton1Click:Connect(function() pause(); farmText.Text='Farm en pause' end)
frame(farm,0,236,409,1,K.line)
text(farm,'TP delay',0,253,170,22,12,K.muted)
text(farm,'1.50 s',319,253,87,22,12,K.ink,true)
text(farm,'Attack delay',0,281,170,22,12,K.muted)
text(farm,'1.95 s',319,281,87,22,12,K.ink,true)

-- Page Tracker : cartes, histogramme et previsions
local tr=pages.Tracker
text(tr,'Counter tracker',0,2,300,27,20,K.ink,true)
local hint=text(tr,'En attente des leaderstats',0,28,398,19,11,K.muted)
local values={}
for i,data in ipairs({{'COUNTERS',0},{'TOTAL',138},{'GAIN SESSION',276}}) do
    local x=data[2]; local card=frame(tr,x,55,133,67,K.panel,7)
    stroke(card)
    text(card,data[1],11,7,119,17,10,K.muted,true)
    values[i]=text(card,'--',11,29,119,29,20,i==3 and K.green or K.ink,true)
end
local info=text(tr,'Départ : -- / --     |     00:00:00',0,131,400,20,11,K.muted)
local chart=frame(tr,0,155,409,56,K.panel,7); stroke(chart)
text(chart,'GAINS / 15 S',10,4,116,14,9,K.muted,true)
local bars={}
for i=1,15 do
    bars[i]=frame(chart,12+(i-1)*26,36,15,11,K.blue,2)
end
text(tr,'PROJECTIONS  ·  total estimé',0,220,380,20,11,K.muted,true)
local predictions={}
for i,h in ipairs({1,2,5,10}) do
    local col=(i-1)%2; local r=math.floor((i-1)/2)
    local x=col*209; local y=245+r*32
    text(tr,h..' h',x,y,36,23,12,K.muted)
    predictions[i]=text(tr,'--',x+40,y,162,23,13,K.ink,true)
end

-- Page Settings
local settings=pages.Settings
text(settings,'Settings',0,2,300,30,20,K.ink,true)
text(settings,'Automatisation',0,43,340,22,11,K.muted,true)
local afkBtn=button(settings,'Anti-AFK (Tab)    ON',0,76,409,42,K.panel)
afkBtn.MouseButton1Click:Connect(function()
    antiAFK=not antiAFK
    afkBtn.Text='Anti-AFK (Tab)    '..(antiAFK and 'ON' or 'OFF')
end)
text(settings,'Une pression toutes les 5 minutes (non garantie).',0,126,407,35,12,K.muted)
frame(settings,0,179,409,1,K.line)
text(settings,'Statistiques',0,191,300,22,11,K.muted,true)
local resetBtn=button(settings,'Réinitialiser le suivi',0,225,409,40,K.panel)
resetBtn.MouseButton1Click:Connect(reset)
text(settings,'Projections d’abord indicatives puis ajustées.',0,277,409,22,11,K.muted)

-- Lecture des valeurs du jeu et mise a jour de l'affichage
local function draw()
    local high=1
    for _,v in ipairs(graphSamples) do high=math.max(high,v) end
    for i,b in ipairs(bars) do
        local v=graphSamples[i] or 0
        local height=math.max(3,math.floor(31*v/high))
        b.Position=UDim2.fromOffset(12+(i-1)*26,52-height)
        b.Size=UDim2.fromOffset(15,height)
        b.BackgroundColor3=v>0 and K.blue or K.line
    end
end
task.spawn(function()
    local ls=P:WaitForChild('leaderstats',15)
    c=ls and ls:WaitForChild('Counters',15)
    t=ls and ls:WaitForChild('Total Counters',15)
    if not c or not t then hint.Text='Statistiques introuvables'; return end
    hint.Text='LIVE  •  Données réelles du jeu'
    local previousGain=0
    while not closed and gui.Parent do
        local sec=seconds()
        local gain=startT and math.max(0,t.Value-startT) or 0
        values[1].Text=number(c.Value)
        values[2].Text=number(t.Value)
        values[3].Text=startT and ('+'..number(gain)) or '--'
        info.Text='Départ : '..(startC and number(startC) or '--')
            ..' / '..(startT and number(startT) or '--')..'    |    '..duration(sec)
        if startT then
            -- Prior observé : 1000/h pendant 120s puis mesure réelle pondérée
            forecast=((1000*120/3600)+gain)/(120+sec)*3600
            for i,h in ipairs({1,2,5,10}) do
                predictions[i].Text=number(math.floor(t.Value+forecast*h+0.5))
            end
            hint.Text='LIVE  •  ~'..number(forecast)..'/h (estimation)'
            if running and sec-lastGraph>=15 then
                table.insert(graphSamples,math.max(0,gain-previousGain))
                if #graphSamples>15 then table.remove(graphSamples,1) end
                lastGraph=sec; previousGain=gain
                draw()
            end
        end
        task.wait(1)
    end
end)

-- Deplacement, reduction et fermeture
local drag,initial,origin=false,nil,nil
head.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or
        input.UserInputType==Enum.UserInputType.Touch then
        drag=true; initial=input.Position; origin=box.Position
    end
end)
local move=UI.InputChanged:Connect(function(input)
    if drag and initial and (input.UserInputType==Enum.UserInputType.MouseMovement or
        input.UserInputType==Enum.UserInputType.Touch) then
        local d=input.Position-initial
        box.Position=UDim2.new(origin.X.Scale,origin.X.Offset+d.X,
            origin.Y.Scale,origin.Y.Offset+d.Y)
    end
end)
local finish=UI.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or
        input.UserInputType==Enum.UserInputType.Touch then drag=false end
end)
local collapsed=false
mini.MouseButton1Click:Connect(function()
    collapsed=not collapsed; sidebar.Visible=not collapsed
    content.Visible=not collapsed
    box.Size=UDim2.fromOffset(600,collapsed and 48 or 390)
    mini.Text=collapsed and '+' or '−'
end)
local function close()
    if closed then return end
    pause(); closed=true
    move:Disconnect(); finish:Disconnect()
    if E.DummyHubStopV55==close then E.DummyHubStopV55=nil end
    gui:Destroy()
end
exit.MouseButton1Click:Connect(close)
E.DummyHubStopV55=close
print('[DUMMY HUB v5.5] Interface + Farm + Tracker charges')
