emptyBox = "958654"

boxGUIDS = {
  nil, nil, nil, nil,
  "93913b",
  "4599b3",
  "d8e506",
  "3f5f47",
  "47cf0b",
  "05dc20"
}

tracks = {
  nil, nil, nil, nil,
  "9c1387",
  "9c1387",
  "1ec9a4",
  "1ec9a4",
  "c09dbd",
  "c09dbd"
}

liberalCards = "c95169"
fascistCards = "50c5b6"
deck = "c95169"

liberals = {
  "6ff0f3",
  "f563fa",
  "9fb888",
  "84b8a6",
  "4a73ed",
  "106af2",
  "19d37d",
  "5604ad",
  "eba99f",
  "a869b8",
  "36a4d6",
  "9de630",
  "0448be",
  "1bb26f",
  "25a803",
  "842cfd",
  "27cab0",
  "ae07c1",
  "da77c2",
  "db16cf",
  "e2589e",
  "bc2dfb",
  "fac883",
  "19be92",
  "1117a5",
  "d1a5ad",
  "0cd95b"
}

fascists = {
  "291868",
  "c34eb5",
  "3a73e9",
  "a03e21",
  "832171",
  "c27cb3",
  "1a6948",
  "2c0b23",
  "d640cb",
  "c888ce",
  "371adc",
  "8a5969"
}

hitlers = {
  "67b490",
  "1cca9d",
  "a6e616",
  "66f78a",
  "c278c6",
  "1c19bd"
}

function onLoad(save_state)
  self.setLock(true)

  local position = self.getPosition()
  position.y = 0
  self.setPosition(position)

  self.setRotation({ x = 180, y = 0, z = 180 })

  self.createButton({
    click_function = "start",
    function_owner = self,
    label = "Start",
    position = { x = 0, y = 0.3, z = 0 },
    width = 500,
    height = 500,
    font_size = 200
  })
end

function start()
  deal()
  track()
  cards()
  self.destruct()
end

function deal()
  players = #getSeatedPlayers()
  box = boxGUIDS[players]
  box = getObjectFromGUID(box)
  box.shuffle()
  box.deal(1)

  Timer.create({
    identifier = "deleteBoxes",
    function_name = "deleteBoxes",
    function_owner = self,
    delay = 0.5
  })

  Timer.create({
    identifier = "openEnvelopes",
    function_name = "openEnvelopes",
    function_owner = self,
    delay = 0.5
  })
end

function openEnvelopes()
  envelopes = {}
  for k, v in ipairs(getSeatedPlayers()) do
    v = Player[v]
    for i = 1, 4 do
      envelope = v.getHandObjects()[1]
      envelope.deal(4, v.color)
      envelopes[v.color] = envelope
    end
  end

  Timer.create({
    identifier = "deleteEnvelopes",
    function_name = "deleteEnvelopes",
    function_owner = self,
    parameters = { envelopes = envelopes },
    delay = 0.5
  })
end

function deleteEnvelopes(p)
  for k, v in pairs(p.envelopes) do
    v.destruct()
  end

  local liberalPlayers, fascistPlayers, hitler = sortRoles(p.envelopes)
  for _, v in pairs(liberalPlayers) do
    v.broadcast("You don't know who anyone is", { r = 0.5, g = 0.5, b = 1 })
    v.broadcast("You are a Liberal", { r = 0.5, g = 0.5, b = 1 })
  end
  for _, v in pairs(fascistPlayers) do
    v.broadcast("Hitler is " .. hitler.color .. ": " .. hitler.steam_name, { r = 1, g = 0.5, b = 0.5 })
    v.broadcast("You are a Fascist", { r = 1, g = 0.5, b = 0.5 })
  end
  if #getSeatedPlayers() == 5 or #getSeatedPlayers() == 6 then
    local fascistAlly = fascistPlayers[1]
    hitler.broadcast("Your fascist ally is " .. fascistAlly.color .. ": " .. fascistAlly.steam_name, { r = 1, g = 0.5, b = 0.5 })
  else
    hitler.broadcast("You don't know who your allies are", { r = 1, g = 0.5, b = 0.5 })
  end
  hitler.broadcast("You are Hitler", { r = 1, g = 0.5, b = 0.5 })
end

function sortRoles(envelopeTable)
  local liberalPlayers = {}
  local fascistPlayers = {}
  local hitler = nil

  for k, v in pairs(envelopeTable) do
    local party = getParty(v)
    if party == "liberal" then
      table.insert(liberalPlayers, Player[k])
    elseif party == "fascist" then
      table.insert(fascistPlayers, Player[k])
    else
      hitler = Player[k]
    end
  end

  return liberalPlayers, fascistPlayers, hitler
end

function getParty(envelope)
  for _, v in pairs(hitlers) do
    if v == envelope.guid then return "hitler" end
  end

  for _, v in pairs(fascists) do
    if v == envelope.guid then return "fascist" end
  end

  for _, v in pairs(liberals) do
    if v == envelope.guid then return "liberal" end
  end
end

function deleteBoxes()
  for i = 1, 10 do
    if not (boxGUIDS[i] == nil) then
      local box = getObjectFromGUID(boxGUIDS[i])
      box.destruct()
    end
  end

  getObjectFromGUID(emptyBox).destruct()
end

function track()
  players = #getSeatedPlayers()
  track = tracks[players]
  trackPosition = getObjectFromGUID(tracks[5]).getPosition()

  deleteTracks(track)

  track = getObjectFromGUID(track)
  track.setPosition(trackPosition)
  track.setLock(true)
end

function deleteTracks(except)
  for i = 1, 10 do
    if not (tracks[i] == nil) and not (tracks[i] == except) then
      local track = getObjectFromGUID(tracks[i])
      track.destruct()
    end
  end
end

function cards()
  joinCards()
end

function joinCards()
  local liberalCards = getObjectFromGUID(liberalCards)
  local fascistCards = getObjectFromGUID(fascistCards)
  fascistCards.setPosition(liberalCards.getPosition())
  Timer.create({
    identifier = "shuffleCards",
    function_name = "shuffleCards",
    function_owner = self,
    delay = 3
  })
end

function shuffleCards()
  local deck = getObjectFromGUID(deck)
  deck.shuffle()
end
