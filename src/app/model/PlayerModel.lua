local PlayerModel = class("PlayerModel")
local _playerInstance = nil
local function changeNilString(str)
	if not str then return '' end
	return str
end


function PlayerModel:getId()
	if not self._id then return '00000' end
	return self._id
end
function PlayerModel:setId(id)
	self._id = id
end
function PlayerModel:setRYId(ryid)
	self._ryId = ryid
end
function PlayerModel:getRYId()
	return self._ryId
end

function PlayerModel:getPName()
	if not self._name then return '没有名字' end
	return self._name
end
function PlayerModel:setPName(name)
	self._name = name
end

function PlayerModel:getPBetNum()
	return self._betNum
end
function PlayerModel:setPBetNum(betnum)
	local MineCtrol = require("mine.MineCtrol")
	MineCtrol.editInfo( {scores = betnum} )
	self._betNum = betnum
end
function PlayerModel:updatePBetNum(betChange)
	self._betNum = self._betNum + betChange
	if self._betNum < 0 then
		local logs = 'PlayerModel:updatePBetNum'
		local explain = 'updatePBetNum '..betChange..'  '..self._betNum
		Single:appLogs(logs, explain)

		self._betNum = 0
	end
end

function PlayerModel:getPDiaNum(  )
	return self._diaNum
end
function PlayerModel:setPDiaNum( diaNum )
	local MineCtrol = require("mine.MineCtrol")
	MineCtrol.editInfo( {diamonds = diaNum} )
	self._diaNum = diaNum
end
function PlayerModel:updatePDiaNum(diaChange)
	self._diaNum = self._diaNum + diaChange
	if self._diaNum < 0 then
		local logs = 'PlayerModel:updatePDiaNum'
		local explain = 'updatePDiaNum '..diaChange..'  '..self._diaNum
		Single:appLogs(logs, explain)

		self._diaNum = 0
	end
end
function PlayerModel:isPDiaNum(diaNum)
	if self._diaNum >= diaNum then return true end
	return false
end

function PlayerModel:getPSex()
	return self._sex
end
function PlayerModel:setPSex(sex)
	self._sex = sex
end


function PlayerModel:getPHeadUrl()
	return changeNilString(self._headUrl)
end
function PlayerModel:setPHeadUrl(headurl)
	self._headUrl = headurl
end

function PlayerModel:getOnlinePerson()
	return self._onLine
end
function PlayerModel:setOnlinePerson(person)
	self._onLine = person
end


function PlayerModel:setMaxCollection(maxc)
	self._maxCollection = maxc
end
function PlayerModel:getMaxCollection()
	return self._maxCollection
end

--获取所在城市
function PlayerModel:getPCity()
	return self._city
end

--设置所在城市
function PlayerModel:setPCity(city)
	self._city = city
end

-- 获取用户编号
function PlayerModel:getPNumber(  )
	if not self._number then return "0000000" end
	return self._number
end

-- 设置用户编号
function PlayerModel:setPNumber( number )
	self._number = number
end


function PlayerModel:ctor()
	--用户id、融云id、用户名、砝码数、砖石、头像地址
	self._id = nil
	self._ryId = nil
	self._name = ''
	self._betNum = 0
	self._diaNum = 0
	self._headUrl = ''

	--在线人数、收藏牌铺数量
	self._onLine = 1
	self._pokerNum = 0

	--最大收藏、性别
	self._maxCollection = 15
	self._sex = 0
	self._number = nil
end

function PlayerModel:getInstance()
	if not _playerInstance then
		_playerInstance = PlayerModel:create()
	end
	return _playerInstance
end

return PlayerModel