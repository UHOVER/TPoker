local Single = {}

function Single:playerModel()
	local PlayerModel = require 'model.PlayerModel'
	return PlayerModel:getInstance()
end

function Single:gameModel()
	local GameModel = require 'model.GameModel'
	return GameModel:getInstance()
end

function Single:paltform()
	local Platform = require ('platform.Platform')
	return Platform:getInstance()
end

function Single:playerManager()
	local PlayerManager = require 'game.PlayerManager'
	return PlayerManager:getInstance()
end

--客户端logs
function Single:appLogs(logs, explain)
	if not explain then
		explain = ''
	end
	if not logs then
		logs = ''
	end
	logs = '客户端: [[说明部分]] '..explain.."  [[详细部分]]  "..logs
	require("app.AppBase"):create():client_logs(logs)
end

function Single:appLogsJson(logs, jsonExplain)
	local explain = jsonExplain
	if type(jsonExplain) == "table" then
		explain = json.encode(jsonExplain)
	end

	logs = '数据出问题 '..logs
	Single:appLogs(logs, explain)
end


function Single:checkGameData(logs)
	print('checkGameData  '..logs)
	Single:appLogs(logs, 'checkGameData')	
	Single:requestGameDataAgain()
end

--重新请求1000更新数据
function Single:requestGameDataAgain()
	-- GAnimation.clearData()

	local GameScene = require 'game.GameScene'
	GameScene.updateGameData()
end

--关闭网络更新数据
function Single:closeWSUpdateData()
	local GameScene = require 'game.GameScene'
	GAnimation.clearData()
	GameScene.NetworkConnectionAgain()
end


return Single