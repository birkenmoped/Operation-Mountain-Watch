-- Operation Mountain Watch - Afghanistan TOWNS discovery configuration.
-- This file is embedded into the generated discovery bundle.
-- Override townsFile in the Mission Editor or pass -TownsFile to the builder
-- when automatic DCS installation discovery is not sufficient.

OMW_TOWNS_DISCOVERY_CONFIG = {
  terrainName = "Afghanistan",
  townsFile = nil,
  outputBaseName = "OMW-Towns-Afghanistan",

  showMarkersOnStart = true,
  createF10Menu = true,
  writeFiles = true,
  logEachTown = true,

  markerLimit = 0,
  markerTextMode = "INDEX_NAME",
  nearestNeighborMaxCount = 2500,
}
