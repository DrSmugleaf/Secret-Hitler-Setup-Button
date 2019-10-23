DEBUG = false

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

Color.add('Fascist', Color(1, 0.5, 0.5))
Color.add('Liberal', Color(0.5, 0.5, 1))

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
  if not DEBUG and (#getSeatedPlayers() < 5 or #getSeatedPlayers() > 10) then
    broadcastToAll("Invalid number of players, must be from 5 to 10", Color.Red)
    return
  end
  deal()
  track()
  cards()
  self.destruct()
end

function deal()
  players = #getSeatedPlayers()
  if not DEBUG then
    box = boxGUIDS[players]
    box = getObjectFromGUID(box)
  else
    box = boxGUIDS[5]
    box = getObjectFromGUID(box)
  end
  box.shuffle()
  box.deal(1)

  Wait.time(deleteBoxes, 0.5)
  Wait.time(openEnvelopes, 0.5)
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

  Wait.time(function() deleteEnvelopes(envelopes) end, 0.5)
end

function deleteEnvelopes(envelopes)
  for k, v in pairs(envelopes) do
    v.destruct()
  end

  local liberalPlayers, fascistPlayers, hitler = sortRoles(envelopes)
  if DEBUG then hitler = Player.White end
  for _, v in pairs(liberalPlayers) do
    v.broadcast("You don't know who anyone is", Color.Liberal)
    v.broadcast("You are a Liberal", Color.Liberal)
  end
  for _, v in pairs(fascistPlayers) do
    v.broadcast("Hitler is " .. hitler.color .. ": " .. hitler.steam_name, Color.Fascist)
    v.broadcast("You are a Fascist", Color.Fascist)
  end
  if #getSeatedPlayers() == 5 or #getSeatedPlayers() == 6 then
    local fascistAlly = fascistPlayers[1]
    hitler.broadcast("Your fascist ally is " .. fascistAlly.color .. ": " .. fascistAlly.steam_name, Color.Fascist)
  else
    hitler.broadcast("You don't know who your allies are", Color.Fascist)
  end
  hitler.broadcast("You are Hitler", Color.Fascist)
end

function sortRoles(envelopeTable)
  local liberalPlayers = {}
  local fascistPlayers = {}
  local hitler = nil

  for k, v in pairs(getSeatedPlayers()) do
    local player = Player[v]
    local role = getPlayerRole(player)
    if role == "Liberal" then table.insert(liberalPlayers, player) end
    if role == "Fascist" then table.insert(fascistPlayers, player) end
    if role == "Hitler" then hitler = player end
  end

  return liberalPlayers, fascistPlayers, hitler
end

function getPlayerRole(player)
  local role = getRole(player)
  if role == "Hitler" then return role end
  return getFaction(player)
end

function getFaction(player)
  for _, v in pairs(player.getHandObjects()) do
    local category = v.getVar("category")
    if category == "Membership Card" then return v.getVar("faction") end
  end
end

function getRole(player)
  for _, v in pairs(player.getHandObjects()) do
    local category = v.getVar("category")
    if category == "Role Card" then return v.getVar("role") end
  end
end

function deleteBoxes()
  for i = 1, 10 do
    if boxGUIDS[i] then
      local box = getObjectFromGUID(boxGUIDS[i])
      box.destruct()
    end
  end

  getObjectFromGUID(emptyBox).destruct()
end

function track()
  players = #getSeatedPlayers()
  track = tracks[players]
  if DEBUG then track = tracks[5] end
  trackPosition = getObjectFromGUID(tracks[5]).getPosition()

  deleteTracks(track)

  track = getObjectFromGUID(track)
  track.setPosition(trackPosition)
  track.setLock(true)
end

function deleteTracks(except)
  for i = 1, 10 do
    if tracks[i] and not (tracks[i] == except) then
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
  Wait.time(function() getObjectFromGUID(deck).shuffle() end, 3)
end
