-- Operation Mountain Watch - generic MOOSE-native logistics authority adapter
-- GROUP/STORAGE logistics use OPSTRANSPORT. Static sling and internal freight use
-- native AUFTRAG constructors. DCS dynamic cargo uses MOOSE EVENTS.
local TAG = "[OMW][AirOps.JBAD.PH1.LOGISTICS]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
local observer = ph1 and ph1.Observer
if not cfg or not ph1 or not observer or not OPSTRANSPORT or not LEGION then
  log("ERROR: MOOSE logistics dependencies unavailable.")
else
  local logistics = ph1.Logistics or { DynamicCargoProfiles = {} }
  ph1.Logistics = logistics

  local function objectName(object)
    if not object then return nil end
    if type(object) == "string" then return object end
    if object.GetName then
      local ok, value = pcall(function() return object:GetName() end)
      if ok then return value end
    end
    return nil
  end

  local function coordinateInZone(coordinate, zone)
    if not coordinate or not zone or not zone.IsCoordinateInZone then return false end
    local ok, value = pcall(function() return zone:IsCoordinateInZone(coordinate) end)
    return ok and value == true
  end

  local function eventCoordinate(eventData)
    if eventData and eventData.IniUnit and eventData.IniUnit.GetCoordinate then
      local ok, value = pcall(function() return eventData.IniUnit:GetCoordinate() end)
      if ok then return value end
    end
    if eventData and eventData.IniGroup and eventData.IniGroup.GetCoordinate then
      local ok, value = pcall(function() return eventData.IniGroup:GetCoordinate() end)
      if ok then return value end
    end
    return nil
  end

  local function nativeState(state, transport)
    if ph1.Controller and ph1.Controller.OnNativeState then
      ph1.Controller:OnNativeState("OPSTRANSPORT", state, transport or ph1.ActiveObject)
    end
  end

  function logistics:AttachCarrierCargoCallbacks(carrier, transport)
    if not carrier or carrier.OMWNativeCargoCallbacksAttached then return end
    carrier.OMWNativeCargoCallbacksAttached = true
    local carrierName = objectName(carrier) or "unknown"

    local previousLoadingDone = carrier.OnAfterLoadingDone
    function carrier:OnAfterLoadingDone(from, event, to)
      if previousLoadingDone then pcall(previousLoadingDone, self, from, event, to) end
      if ph1.ActiveObject ~= transport or not ph1.Runtime then return end
      ph1.Runtime.NativeCarrierLoadingDoneGroups = ph1.Runtime.NativeCarrierLoadingDoneGroups or {}
      ph1.Runtime.NativeCarrierLoadingDoneGroups[carrierName] = true
      ph1.Runtime.NativeCarrierLoadingDone = true
      log(string.format("NATIVE_CARRIER_CARGO event=LoadingDone carrier=%s profile=%s", carrierName, tostring(transport.OMWMetadata and transport.OMWMetadata.Profile)))
    end

    local previousUnloadingDone = carrier.OnAfterUnloadingDone
    function carrier:OnAfterUnloadingDone(from, event, to)
      if previousUnloadingDone then pcall(previousUnloadingDone, self, from, event, to) end
      if ph1.ActiveObject ~= transport or not ph1.Runtime then return end
      ph1.Runtime.NativeCarrierUnloadingDoneGroups = ph1.Runtime.NativeCarrierUnloadingDoneGroups or {}
      ph1.Runtime.NativeCarrierUnloadingDoneGroups[carrierName] = true
      ph1.Runtime.NativeCarrierUnloadingDone = true
      log(string.format("NATIVE_CARRIER_CARGO event=UnloadingDone carrier=%s profile=%s", carrierName, tostring(transport.OMWMetadata and transport.OMWMetadata.Profile)))
      logistics:RefreshObjective()
    end
  end

  function logistics:BindTransportCarriers(transport, source)
    if ph1.ActiveObject ~= transport or not ph1.Runtime then return 0 end
    local count = 0
    for _, carrier in pairs(transport:GetCarriers() or {}) do
      self:AttachCarrierCargoCallbacks(carrier, transport)
      if observer:BindFlightGroup(carrier, transport, source or "OPSTRANSPORT") then count = count + 1 end
    end
    return count
  end

  local function bindAfterEvent(transport, source)
    if SCHEDULER then
      SCHEDULER:New(nil, function() logistics:BindTransportCarriers(transport, source) end, {}, 0.1)
    else
      logistics:BindTransportCarriers(transport, source)
    end
  end

  local function validateGroupCargoIdentity(metadata, cargo)
    if metadata.Profile ~= "GROUP_CARGO" or not metadata.CargoName then return true end
    local actual = objectName(cargo)
    if actual ~= metadata.CargoName and ph1.Runtime then
      ph1.Runtime.HardFailure = "wrong-native-cargo-" .. tostring(actual)
      return false
    end
    return true
  end

  local function installTransportCallbacks(transport, metadata)
    transport.OMWMetadata = metadata

    local previousQueued = transport.OnAfterQueued
    function transport:OnAfterQueued(from, event, to)
      if previousQueued then pcall(previousQueued, self, from, event, to) end
      if ph1.ActiveObject ~= self then return end
      nativeState("QUEUED", self)
      log("NATIVE_TRANSPORT state=QUEUED operation=" .. tostring(metadata.TestId))
    end

    local previousRequested = transport.OnAfterRequested
    function transport:OnAfterRequested(from, event, to)
      if previousRequested then pcall(previousRequested, self, from, event, to) end
      if ph1.ActiveObject ~= self then return end
      nativeState("REQUESTED", self)
      log("NATIVE_TRANSPORT state=REQUESTED operation=" .. tostring(metadata.TestId))
    end

    local previousScheduled = transport.OnAfterScheduled
    function transport:OnAfterScheduled(from, event, to)
      if previousScheduled then pcall(previousScheduled, self, from, event, to) end
      if ph1.ActiveObject ~= self then return end
      nativeState("SCHEDULED", self)
      bindAfterEvent(self, "OPSTRANSPORT_SCHEDULED")
      log("NATIVE_TRANSPORT state=SCHEDULED operation=" .. tostring(metadata.TestId))
    end

    local previousExecuting = transport.OnAfterExecuting
    function transport:OnAfterExecuting(from, event, to)
      if previousExecuting then pcall(previousExecuting, self, from, event, to) end
      if ph1.ActiveObject ~= self then return end
      nativeState("EXECUTING", self)
      bindAfterEvent(self, "OPSTRANSPORT_EXECUTING")
      log("NATIVE_TRANSPORT state=EXECUTING operation=" .. tostring(metadata.TestId))
    end

    local previousLoaded = transport.OnAfterLoaded
    function transport:OnAfterLoaded(from, event, to, cargo, carrier, carrierElement)
      if previousLoaded then pcall(previousLoaded, self, from, event, to, cargo, carrier, carrierElement) end
      if ph1.ActiveObject ~= self or not ph1.Runtime then return end
      logistics:AttachCarrierCargoCallbacks(carrier, self)
      observer:BindFlightGroup(carrier, self, "OPSTRANSPORT_LOADED")
      if not validateGroupCargoIdentity(metadata, cargo) then return end
      ph1.Runtime.NativeCargoLoaded = true
      ph1.Runtime.NativeCargoLoadedName = objectName(cargo)
      log(string.format("NATIVE_CARGO event=Loaded operation=%s profile=%s cargo=%s carrier=%s pickupLanding=%s",
        tostring(metadata.TestId), tostring(metadata.Profile), tostring(objectName(cargo)), tostring(objectName(carrier)), tostring(ph1.Runtime.PickupLandingObserved)))
    end

    local previousUnloaded = transport.OnAfterUnloaded
    function transport:OnAfterUnloaded(from, event, to, cargo, carrier)
      if previousUnloaded then pcall(previousUnloaded, self, from, event, to, cargo, carrier) end
      if ph1.ActiveObject ~= self or not ph1.Runtime then return end
      logistics:AttachCarrierCargoCallbacks(carrier, self)
      observer:BindFlightGroup(carrier, self, "OPSTRANSPORT_UNLOADED")
      if not validateGroupCargoIdentity(metadata, cargo) then return end
      ph1.Runtime.NativeCargoUnloaded = true
      ph1.Runtime.NativeCargoUnloadedName = objectName(cargo)
      log(string.format("NATIVE_CARGO event=Unloaded operation=%s profile=%s cargo=%s carrier=%s dropoffLanding=%s",
        tostring(metadata.TestId), tostring(metadata.Profile), tostring(objectName(cargo)), tostring(objectName(carrier)), tostring(ph1.Runtime.DropoffLandingObserved)))
      logistics:RefreshObjective()
    end

    local previousDelivered = transport.OnAfterDelivered
    function transport:OnAfterDelivered(from, event, to)
      if previousDelivered then pcall(previousDelivered, self, from, event, to) end
      if ph1.ActiveObject ~= self or not ph1.Runtime then return end
      ph1.Runtime.NativeTransportDelivered = true
      nativeState("DELIVERED", self)
      bindAfterEvent(self, "OPSTRANSPORT_DELIVERED")
      logistics:RefreshObjective()
      log(string.format("NATIVE_TRANSPORT state=DELIVERED operation=%s profile=%s delivered=%d/%d",
        tostring(metadata.TestId), tostring(metadata.Profile), self:GetNcargoDelivered(), self:GetNcargoTotal()))
    end

    local previousCancel = transport.OnAfterCancel
    function transport:OnAfterCancel(from, event, to)
      if previousCancel then pcall(previousCancel, self, from, event, to) end
      if ph1.ActiveObject ~= self then return end
      nativeState("CANCELLED", self)
      log("NATIVE_TRANSPORT state=CANCELLED operation=" .. tostring(metadata.TestId))
    end

    return transport
  end

  function logistics:CreateGroupTransport(definition, cargoGroup, pickupZone, deployZone)
    if not cargoGroup or not pickupZone or not deployZone then return nil, "group-transport-input-missing" end
    local transport = OPSTRANSPORT:New(cargoGroup, pickupZone, deployZone)
    if not transport then return nil, "OPSTRANSPORT-construction-failed" end
    transport:SetRequiredCarriers(definition.ExpectedGroups, definition.ExpectedGroups)
    transport:SetRequiredCargos(cargoGroup)
    transport:SetDisembarkZone(deployZone)
    transport:SetDisembarkActivation(true)
    transport:SetPriority(20, 1, false)
    installTransportCallbacks(transport, {
      TestId = definition.Id,
      Profile = definition.LogisticsProfile,
      CargoName = cargoGroup:GetName(),
      PickupZone = pickupZone,
      DeployZone = deployZone,
      CarrierSquadronKey = definition.SquadronKey
    })
    log(string.format("LOGISTICS_CREATED operation=%s authority=OPSTRANSPORT profile=%s cargo=%s pickup=%s deploy=%s carrierSquadron=%s",
      definition.Id, tostring(definition.LogisticsProfile), cargoGroup:GetName(), pickupZone:GetName(), deployZone:GetName(), definition.SquadronKey))
    return transport
  end

  function logistics:CreateStorageTransport(spec)
    if not spec or not spec.PickupZone or not spec.DeployZone or not spec.StorageFrom or not spec.StorageTo then
      return nil, "storage-transport-input-missing"
    end
    local amount = tonumber(spec.CargoAmount) or 0
    if amount <= 0 then return nil, "storage-cargo-amount-invalid" end
    local transport = OPSTRANSPORT:New(nil, spec.PickupZone, spec.DeployZone)
    transport:SetRequiredCarriers(spec.RequiredCarriersMin or 1, spec.RequiredCarriersMax or spec.RequiredCarriersMin or 1)
    transport:AddCargoStorage(spec.StorageFrom, spec.StorageTo, spec.CargoType, amount, spec.CargoWeight or 1)
    transport:SetPriority(spec.Priority or 50, spec.Importance, spec.Urgent)
    installTransportCallbacks(transport, {
      TestId = spec.Id or "STORAGE_LOGISTICS",
      Profile = "STORAGE_CARGO",
      PickupZone = spec.PickupZone,
      DeployZone = spec.DeployZone,
      CarrierSquadronKey = spec.CarrierSquadronKey or "CH47",
      StorageSpec = spec
    })
    log(string.format("LOGISTICS_CREATED operation=%s authority=OPSTRANSPORT profile=STORAGE_CARGO carrierSquadron=%s cargoType=%s amount=%d",
      tostring(spec.Id or "STORAGE_LOGISTICS"), tostring(spec.CarrierSquadronKey or "CH47"), tostring(spec.CargoType), amount))
    return transport
  end

  local function transportCargoWeights(transport, metadata)
    if metadata.Profile == "GROUP_CARGO" then
      local maximum, total = 0, 0
      for _, cargo in pairs(transport:GetCargoOpsGroups(false) or {}) do
        local weight = cargo.GetWeightTotal and cargo:GetWeightTotal() or 0
        maximum = math.max(maximum, weight)
        total = total + weight
      end
      if total <= 0 then return nil, nil, "group-cargo-weight-unavailable" end
      return maximum, total
    end
    if metadata.Profile == "STORAGE_CARGO" then
      local spec = metadata.StorageSpec or {}
      local itemWeight = tonumber(spec.CargoWeight) or 1
      local amount = tonumber(spec.CargoAmount) or 0
      if amount <= 0 then return nil, nil, "storage-cargo-amount-invalid" end
      return itemWeight, itemWeight * amount
    end
    return nil, nil, nil
  end

  local function recruitExactCarrierCohort(transport, metadata)
    local squadron = cfg.Squadrons and cfg.Squadrons[metadata.CarrierSquadronKey] or nil
    if not squadron then return false, nil, nil, "carrier-squadron-unavailable-" .. tostring(metadata.CarrierSquadronKey) end
    local minimum, maximum = transport:GetRequiredCarriers()
    local cargoWeight, totalWeight, weightError = transportCargoWeights(transport, metadata)
    if weightError then return false, nil, nil, weightError end
    local deploy = transport:GetDeployZone()
    local target = deploy and deploy:GetVec2() or nil
    local recruited, assets, legions = LEGION.RecruitCohortAssets(
      { squadron }, AUFTRAG.Type.OPSTRANSPORT, AUFTRAG.Type.OPSTRANSPORT,
      minimum, maximum, target, nil, nil, nil, cargoWeight, totalWeight
    )
    return recruited, assets, legions, recruited and nil or "MOOSE-exact-cohort-recruitment-failed"
  end

  function logistics:DispatchTransport(transport)
    if not transport then return false, "transport-missing" end
    local metadata = transport.OMWMetadata or {}
    local recruited, assets, legions, reason
    if metadata.CarrierSquadronKey then
      recruited, assets, legions, reason = recruitExactCarrierCohort(transport, metadata)
    else
      recruited, assets, legions = cfg.Airwing:RecruitAssetsForTransport(transport)
      reason = recruited and nil or "MOOSE-airwing-transport-recruitment-failed"
    end
    if not recruited or not assets or #assets == 0 then return false, reason or "MOOSE-transport-assets-unavailable" end
    for _, asset in pairs(assets) do transport:AddAsset(asset) end
    cfg.Airwing:TransportAssign(transport, legions)
    log(string.format("LOGISTICS_DISPATCH authority=OPSTRANSPORT profile=%s carrierSquadron=%s assets=%d requiredCarriers=%d",
      tostring(metadata.Profile), tostring(metadata.CarrierSquadronKey or "AUTO"), #assets, select(1, transport:GetRequiredCarriers())))
    return true
  end

  function logistics:OnCarrierLanding(groupName, eventData)
    if not ph1.Runtime or not ph1.ActiveDefinition or ph1.ActiveDefinition.OperationKind ~= "OPSTRANSPORT" then return end
    local metadata = ph1.ActiveObject and ph1.ActiveObject.OMWMetadata or {}
    local coordinate = eventCoordinate(eventData)
    if coordinateInZone(coordinate, metadata.PickupZone) and not ph1.Runtime.NativeCargoLoaded then
      ph1.Runtime.PickupLandingObserved = true
      log("LOGISTICS_PHYSICAL event=PICKUP_LANDING group=" .. tostring(groupName))
    elseif coordinateInZone(coordinate, metadata.DeployZone) and ph1.Runtime.NativeCargoLoaded then
      ph1.Runtime.DropoffLandingObserved = true
      log("LOGISTICS_PHYSICAL event=DROPOFF_LANDING group=" .. tostring(groupName))
    else
      log("LOGISTICS_PHYSICAL event=UNCLASSIFIED_OPERATIONAL_LANDING group=" .. tostring(groupName))
    end
  end

  local function groupAliveInZone(groupName, zone)
    local group = groupName and GROUP and GROUP:FindByName(groupName) or nil
    if not group or not group:IsAlive() or not zone then return false end
    if group.IsAnyInZone then
      local ok, value = pcall(function() return group:IsAnyInZone(zone) end)
      if ok then return value == true end
    end
    return coordinateInZone(group:GetCoordinate(), zone)
  end

  function logistics:ArmFinalDespawn()
    if not ph1.Runtime or ph1.Runtime.FinalDespawnArmed or not ph1.Runtime.ObjectiveSatisfied then return false end
    local armed = 0
    for _, flightgroup in pairs(ph1.Runtime.FlightGroups or {}) do
      if flightgroup.SetDespawnAfterLanding then
        local ok = pcall(function() flightgroup:SetDespawnAfterLanding() end)
        if ok then armed = armed + 1 end
      end
    end
    if armed > 0 then
      ph1.Runtime.FinalDespawnArmed = true
      log("LOGISTICS_FINAL_DESPAWN armedFlightGroups=" .. tostring(armed) .. " afterNativeDelivery=true")
      return true
    end
    return false
  end

  local function verifyStorageDelivery(metadata, transport)
    local verifier = metadata.StorageSpec and metadata.StorageSpec.VerifyDelivered or nil
    if not verifier then return true, false end
    local ok, value = pcall(verifier, metadata.StorageSpec, transport)
    if not ok then
      if ph1.Runtime then ph1.Runtime.HardFailure = "storage-delivery-verifier-error-" .. tostring(value) end
      return false, true
    end
    return value == true, true
  end

  function logistics:RefreshObjective()
    local runtime = ph1.Runtime
    local definition = ph1.ActiveDefinition
    if not runtime or not definition or runtime.ObjectiveSatisfied then return runtime and runtime.ObjectiveSatisfied or false end

    if definition.LogisticsProfile == "GROUP_CARGO" then
      local transport = ph1.ActiveObject
      local metadata = transport and transport.OMWMetadata or {}
      local delivered = transport and transport.GetNcargoDelivered and transport:GetNcargoDelivered() or 0
      local total = transport and transport.GetNcargoTotal and transport:GetNcargoTotal() or 0
      local physicallyDelivered = groupAliveInZone(runtime.CargoGroupName, metadata.DeployZone)
      if runtime.PickupLandingObserved and runtime.NativeCargoLoaded and runtime.NativeCarrierLoadingDone and
         runtime.DropoffLandingObserved and runtime.NativeCargoUnloaded and runtime.NativeCarrierUnloadingDone and
         runtime.NativeTransportDelivered and total > 0 and delivered == total and physicallyDelivered then
        runtime.ObjectiveSatisfied = true
        log("LOGISTICS_OBJECTIVE PASS profile=GROUP_CARGO Loaded+LoadingDone+Unloaded+UnloadingDone+Delivered=true physicalCargoAtDeploy=true")
        self:ArmFinalDespawn()
      end
    elseif definition.LogisticsProfile == "STORAGE_CARGO" then
      local transport = ph1.ActiveObject
      local metadata = transport and transport.OMWMetadata or {}
      local delivered = transport and transport.GetNcargoDelivered and transport:GetNcargoDelivered() or 0
      local total = transport and transport.GetNcargoTotal and transport:GetNcargoTotal() or 0
      local verified, customVerifier = verifyStorageDelivery(metadata, transport)
      if runtime.NativeCarrierLoadingDone and runtime.NativeCarrierUnloadingDone and runtime.NativeTransportDelivered and
         total > 0 and delivered == total and verified then
        runtime.ObjectiveSatisfied = true
        log("LOGISTICS_OBJECTIVE PASS profile=STORAGE_CARGO LoadingDone+UnloadingDone+Delivered=true customStorageVerification=" .. tostring(customVerifier))
        self:ArmFinalDespawn()
      end
    elseif definition.LogisticsProfile == "STATIC_SLING_CARGO" then
      local cargo = STATIC and STATIC:FindByName(ph1.Objects.CH47Cargo, false) or nil
      local zone = ZONE and ZONE:FindByName(ph1.Objects.CH47DropZone) or nil
      if runtime.NativeState == "SUCCESS" and cargo and zone and cargo:IsInZone(zone) then
        runtime.ObjectiveSatisfied = true
        log("LOGISTICS_OBJECTIVE PASS profile=STATIC_SLING_CARGO nativeAuftragSuccess=true physicalCargoAtDrop=true")
        self:ArmFinalDespawn()
      end
    elseif definition.LogisticsProfile == "STATIC_FREIGHT_CARGO" then
      if runtime.NativeState == "SUCCESS" then
        runtime.ObjectiveSatisfied = true
        log("LOGISTICS_OBJECTIVE PASS profile=STATIC_FREIGHT_CARGO nativeAuftragSuccess=true")
        self:ArmFinalDespawn()
      end
    elseif definition.LogisticsProfile == "DYNAMIC_CARGO" then
      if runtime.DynamicCargoLoaded and runtime.DynamicCargoUnloaded then
        runtime.ObjectiveSatisfied = true
        log("LOGISTICS_OBJECTIVE PASS profile=DYNAMIC_CARGO nativeEvents=true")
        self:ArmFinalDespawn()
      end
    end
    return runtime.ObjectiveSatisfied == true
  end

  function logistics:RegisterDynamicCargoProfile(name, spec)
    self.DynamicCargoProfiles[name] = spec or {}
  end

  local dynamicHandler = EVENTHANDLER:New()
  if EVENTS.DynamicCargoLoaded and EVENTS.DynamicCargoLoaded ~= -1 then dynamicHandler:HandleEvent(EVENTS.DynamicCargoLoaded) end
  if EVENTS.DynamicCargoUnloaded and EVENTS.DynamicCargoUnloaded ~= -1 then dynamicHandler:HandleEvent(EVENTS.DynamicCargoUnloaded) end
  if EVENTS.DynamicCargoRemoved and EVENTS.DynamicCargoRemoved ~= -1 then dynamicHandler:HandleEvent(EVENTS.DynamicCargoRemoved) end

  function dynamicHandler:OnEventDynamicCargoLoaded(eventData)
    if not ph1.Runtime or not ph1.ActiveDefinition or ph1.ActiveDefinition.LogisticsProfile ~= "DYNAMIC_CARGO" then return end
    ph1.Runtime.DynamicCargoLoaded = true
    ph1.Runtime.DynamicCargoName = eventData.IniDynamicCargoName
    log("NATIVE_DYNAMIC_CARGO event=Loaded cargo=" .. tostring(eventData.IniDynamicCargoName))
  end
  function dynamicHandler:OnEventDynamicCargoUnloaded(eventData)
    if not ph1.Runtime or not ph1.ActiveDefinition or ph1.ActiveDefinition.LogisticsProfile ~= "DYNAMIC_CARGO" then return end
    ph1.Runtime.DynamicCargoUnloaded = true
    ph1.Runtime.DynamicCargoName = eventData.IniDynamicCargoName
    log("NATIVE_DYNAMIC_CARGO event=Unloaded cargo=" .. tostring(eventData.IniDynamicCargoName))
    logistics:RefreshObjective()
  end
  function dynamicHandler:OnEventDynamicCargoRemoved(eventData)
    if not ph1.Runtime or not ph1.ActiveDefinition or ph1.ActiveDefinition.LogisticsProfile ~= "DYNAMIC_CARGO" then return end
    ph1.Runtime.DynamicCargoRemoved = true
    log("NATIVE_DYNAMIC_CARGO event=Removed cargo=" .. tostring(eventData.IniDynamicCargoName))
  end

  log("READY profiles=GROUP/STORAGE/STATIC_SLING/STATIC_FREIGHT/DYNAMIC nativeCarrierCargoEvents=LoadingDone/UnloadingDone nativeTransportEvents=Loaded/Unloaded/Delivered")
end
