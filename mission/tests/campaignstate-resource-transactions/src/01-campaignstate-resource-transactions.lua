local TEST_ID = "CAMPAIGNSTATE-RESOURCE-TRANSACTION-1"
local TAG = "[OMW][TEST][CampaignStateResourceTransaction]"

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(label, expected, actual)
  error(string.format("%s ASSERT_FAIL label=%s expected=%s actual=%s", TAG, tostring(label), tostring(expected), tostring(actual)), 2)
end

local function assertEqual(label, expected, actual)
  if expected ~= actual then
    fail(label, expected, actual)
  end
end

local function assertTrue(label, value)
  if value ~= true then
    fail(label, true, value)
  end
end

local function expectFailure(label, fn)
  local ok, err = pcall(fn)
  if ok then
    error(TAG .. " ASSERT_FAIL expected failure label=" .. tostring(label), 2)
  end
  log(string.format("EXPECTED_FAILURE_PASS label=%s error=%s", tostring(label), tostring(err)))
end

local store = OMWCampaignState.New({
  schemaVersion = "CAMPAIGNSTATE-RESOURCE-TRANSACTION-TEST-1",
  nodes = {
    {
      nodeId = "TEST_NODE_ALPHA",
      airbaseName = "Bagram",
      resourcesKg = {
        [OMWCampaignState.ResourceId.JP8] = 10000,
        [OMWCampaignState.ResourceId.AVGAS] = 2000,
      },
    },
    {
      nodeId = "TEST_NODE_BRAVO",
      airbaseName = "Jalalabad",
      resourcesKg = {
        [OMWCampaignState.ResourceId.JP8] = 1000,
        [OMWCampaignState.ResourceId.AVGAS] = 1000,
      },
    },
    {
      nodeId = "TEST_NODE_CHARLIE",
      airbaseName = "Kandahar",
      resourcesKg = {
        [OMWCampaignState.ResourceId.JP8] = 0,
        [OMWCampaignState.ResourceId.AVGAS] = 0,
      },
    },
  },
})

log("BEGIN testId=" .. TEST_ID)

-- Legacy fuel mirror compatibility.
do
  local snapshot = store:GetFuelSnapshot("TEST_NODE_ALPHA")
  assertEqual("legacy.jp8", 10000, snapshot.resourcesKg[OMWCampaignState.ResourceId.JP8])
  assertEqual("legacy.avgas", 2000, snapshot.resourcesKg[OMWCampaignState.ResourceId.AVGAS])
  log("LEGACY_FUEL_SNAPSHOT_PASS")
end

-- Successful transfer with one-time debit/credit and terminal idempotency.
do
  local tx, changed = store:ReserveResource({
    transactionId = "TX_TRANSFER_001",
    reservationId = "RES_TRANSFER_001",
    cargoId = "CARGO_TRANSFER_001",
    missionDemandId = "DEMAND_TRANSFER_001",
    carrierEntityId = "CARRIER_TEST_001",
    kind = OMWCampaignState.TransactionKind.TRANSFER,
    resourceId = OMWCampaignState.ResourceId.JP8,
    quantity = 2000,
    canonicalUnit = OMWCampaignState.Unit.KG,
    originNodeId = "TEST_NODE_ALPHA",
    destinationNodeId = "TEST_NODE_BRAVO",
  })
  assertTrue("transfer.reserve.changed", changed)
  assertEqual("transfer.reserve.status", OMWCampaignState.TransactionStatus.RESERVED, tx.status)
  assertEqual("transfer.reserve.available", 8000, store:GetResource("TEST_NODE_ALPHA", OMWCampaignState.ResourceId.JP8).available)

  local duplicate, duplicateChanged = store:ReserveResource({
    transactionId = "TX_TRANSFER_001",
    reservationId = "RES_TRANSFER_001",
    cargoId = "CARGO_TRANSFER_001",
    missionDemandId = "DEMAND_TRANSFER_001",
    carrierEntityId = "CARRIER_TEST_001",
    kind = OMWCampaignState.TransactionKind.TRANSFER,
    resourceId = OMWCampaignState.ResourceId.JP8,
    quantity = 2000,
    canonicalUnit = OMWCampaignState.Unit.KG,
    originNodeId = "TEST_NODE_ALPHA",
    destinationNodeId = "TEST_NODE_BRAVO",
  })
  assertEqual("transfer.duplicate.changed", false, duplicateChanged)
  assertEqual("transfer.duplicate.status", OMWCampaignState.TransactionStatus.RESERVED, duplicate.status)

  store:MarkLoading("TX_TRANSFER_001")
  store:MarkInTransit("TX_TRANSFER_001")
  assertEqual("transfer.origin.debited", 8000, store:GetResource("TEST_NODE_ALPHA", OMWCampaignState.ResourceId.JP8).quantity)
  assertEqual("transfer.origin.reserved.released", 0, store:GetResource("TEST_NODE_ALPHA", OMWCampaignState.ResourceId.JP8).reserved)
  assertEqual("transfer.destination.notYetCredited", 1000, store:GetResource("TEST_NODE_BRAVO", OMWCampaignState.ResourceId.JP8).quantity)

  local delivered, deliveredChanged = store:MarkDelivered("TX_TRANSFER_001")
  assertTrue("transfer.delivered.changed", deliveredChanged)
  assertEqual("transfer.delivered.status", OMWCampaignState.TransactionStatus.DELIVERED, delivered.status)
  assertEqual("transfer.destination.credited", 3000, store:GetResource("TEST_NODE_BRAVO", OMWCampaignState.ResourceId.JP8).quantity)

  local deliveredAgain, deliveredAgainChanged = store:MarkDelivered("TX_TRANSFER_001")
  assertEqual("transfer.deliveredAgain.changed", false, deliveredAgainChanged)
  assertEqual("transfer.deliveredAgain.status", OMWCampaignState.TransactionStatus.DELIVERED, deliveredAgain.status)
  assertEqual("transfer.destination.oneTimeCredit", 3000, store:GetResource("TEST_NODE_BRAVO", OMWCampaignState.ResourceId.JP8).quantity)
  log("TRANSFER_DELIVERY_IDEMPOTENCY_PASS")
end

-- Consumption reserves first, then debits exactly once.
do
  local _, changed = store:ReserveResource({
    transactionId = "TX_CONSUME_001",
    reservationId = "RES_CONSUME_001",
    kind = OMWCampaignState.TransactionKind.CONSUMPTION,
    resourceId = OMWCampaignState.ResourceId.AVGAS,
    quantity = 500,
    canonicalUnit = OMWCampaignState.Unit.KG,
    originNodeId = "TEST_NODE_ALPHA",
  })
  assertTrue("consume.reserve.changed", changed)
  assertEqual("consume.reserve.available", 1500, store:GetResource("TEST_NODE_ALPHA", OMWCampaignState.ResourceId.AVGAS).available)

  local consumed, consumedChanged = store:Consume("TX_CONSUME_001")
  assertTrue("consume.changed", consumedChanged)
  assertEqual("consume.status", OMWCampaignState.TransactionStatus.CONSUMED, consumed.status)
  assertEqual("consume.origin.quantity", 1500, store:GetResource("TEST_NODE_ALPHA", OMWCampaignState.ResourceId.AVGAS).quantity)
  assertEqual("consume.origin.reserved", 0, store:GetResource("TEST_NODE_ALPHA", OMWCampaignState.ResourceId.AVGAS).reserved)

  local consumedAgain, consumedAgainChanged = store:Consume("TX_CONSUME_001")
  assertEqual("consume.again.changed", false, consumedAgainChanged)
  assertEqual("consume.again.status", OMWCampaignState.TransactionStatus.CONSUMED, consumedAgain.status)
  assertEqual("consume.oneTimeDebit", 1500, store:GetResource("TEST_NODE_ALPHA", OMWCampaignState.ResourceId.AVGAS).quantity)
  log("CONSUMPTION_IDEMPOTENCY_PASS")
end

-- Cancellation releases reservation without changing stock.
do
  store:ReserveResource({
    transactionId = "TX_CANCEL_001",
    reservationId = "RES_CANCEL_001",
    cargoId = "CARGO_CANCEL_001",
    kind = OMWCampaignState.TransactionKind.TRANSFER,
    resourceId = OMWCampaignState.ResourceId.JP8,
    quantity = 1000,
    originNodeId = "TEST_NODE_ALPHA",
    destinationNodeId = "TEST_NODE_CHARLIE",
  })
  assertEqual("cancel.reserved", 1000, store:GetResource("TEST_NODE_ALPHA", OMWCampaignState.ResourceId.JP8).reserved)
  local cancelled, cancelChanged = store:Cancel("TX_CANCEL_001")
  assertTrue("cancel.changed", cancelChanged)
  assertEqual("cancel.status", OMWCampaignState.TransactionStatus.CANCELLED, cancelled.status)
  assertEqual("cancel.stockUnchanged", 8000, store:GetResource("TEST_NODE_ALPHA", OMWCampaignState.ResourceId.JP8).quantity)
  assertEqual("cancel.reservationReleased", 0, store:GetResource("TEST_NODE_ALPHA", OMWCampaignState.ResourceId.JP8).reserved)
  local _, cancelAgainChanged = store:Cancel("TX_CANCEL_001")
  assertEqual("cancel.idempotent", false, cancelAgainChanged)
  log("CANCELLATION_RELEASE_PASS")
end

-- Lost transfer debits origin in transit and never credits destination.
do
  store:ReserveResource({
    transactionId = "TX_LOST_001",
    reservationId = "RES_LOST_001",
    cargoId = "CARGO_LOST_001",
    kind = OMWCampaignState.TransactionKind.TRANSFER,
    resourceId = OMWCampaignState.ResourceId.JP8,
    quantity = 750,
    originNodeId = "TEST_NODE_ALPHA",
    destinationNodeId = "TEST_NODE_CHARLIE",
  })
  store:MarkLoading("TX_LOST_001")
  store:MarkInTransit("TX_LOST_001")
  assertEqual("lost.origin.debited", 7250, store:GetResource("TEST_NODE_ALPHA", OMWCampaignState.ResourceId.JP8).quantity)
  local lost, lostChanged = store:MarkLost("TX_LOST_001")
  assertTrue("lost.changed", lostChanged)
  assertEqual("lost.status", OMWCampaignState.TransactionStatus.LOST, lost.status)
  assertEqual("lost.destination.noCredit", 0, store:GetResource("TEST_NODE_CHARLIE", OMWCampaignState.ResourceId.JP8).quantity)
  local _, lostAgainChanged = store:MarkLost("TX_LOST_001")
  assertEqual("lost.idempotent", false, lostAgainChanged)
  log("LOSS_NO_DESTINATION_CREDIT_PASS")
end

-- Reservation safety and transaction identity conflict checks.
do
  expectFailure("over-reservation", function()
    store:ReserveResource({
      transactionId = "TX_OVER_001",
      kind = OMWCampaignState.TransactionKind.TRANSFER,
      resourceId = OMWCampaignState.ResourceId.JP8,
      quantity = 8000,
      originNodeId = "TEST_NODE_ALPHA",
      destinationNodeId = "TEST_NODE_BRAVO",
    })
  end)

  expectFailure("transaction-id-conflict", function()
    store:ReserveResource({
      transactionId = "TX_TRANSFER_001",
      reservationId = "RES_TRANSFER_001",
      cargoId = "CARGO_TRANSFER_001",
      missionDemandId = "DEMAND_TRANSFER_001",
      carrierEntityId = "CARRIER_TEST_001",
      kind = OMWCampaignState.TransactionKind.TRANSFER,
      resourceId = OMWCampaignState.ResourceId.JP8,
      quantity = 1999,
      originNodeId = "TEST_NODE_ALPHA",
      destinationNodeId = "TEST_NODE_BRAVO",
    })
  end)

  log("RESERVATION_AND_IDENTITY_GUARDS_PASS")
end

-- Final invariants.
assertEqual("final.alpha.jp8", 7250, store:GetResource("TEST_NODE_ALPHA", OMWCampaignState.ResourceId.JP8).quantity)
assertEqual("final.alpha.avgas", 1500, store:GetResource("TEST_NODE_ALPHA", OMWCampaignState.ResourceId.AVGAS).quantity)
assertEqual("final.bravo.jp8", 3000, store:GetResource("TEST_NODE_BRAVO", OMWCampaignState.ResourceId.JP8).quantity)
assertEqual("final.charlie.jp8", 0, store:GetResource("TEST_NODE_CHARLIE", OMWCampaignState.ResourceId.JP8).quantity)

log("RESULT testId=" .. TEST_ID .. " status=PASS transferDelivery=true consumption=true cancellation=true loss=true oneTimeCredit=true oneTimeDebit=true reservationGuard=true transactionIdentity=true persistence=false mooseTransport=false dcsStorageMutation=false")
